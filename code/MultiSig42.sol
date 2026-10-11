// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IERC20} from "@openzeppelin/contracts@5.6.1/token/ERC20/IERC20.sol";


/// @title MultiSig42
/// @author ndesprez
/// @notice A 2-of-2 multisig wallet that holds a treasury of Token42 (T42).
/// @dev Two signers are fixed at deployment. Either signer can propose to send T42 from this
///      contract to an address; the transfer only happens once both signers have confirmed.
///      There is no owner and no way to change the signers or the threshold after deployment.

contract MultiSig42 {
    /// @dev A request to send `amount` T42 (in base units) from this contract to `to`.
    struct Proposal {
        address to;
        uint256 amount;
        uint256 confirmationCount;
        bool executed;
    }

    /// @notice Number of signer confirmations needed before a proposal can be executed (both signers).
    uint256 public constant REQUIRED_CONFIRMATIONS = 2;

    /// @notice The T42 token held by this multisig.
    IERC20 public immutable token;

    /// @notice The two signers, fixed at deployment.
    address public immutable signer1;
    address public immutable signer2;

    /// @notice Every proposal ever submitted; its index in this list is its id.
    Proposal[] public proposals;

    /// @notice hasConfirmed[proposalId][signer] is true once that signer has confirmed that proposal.
    mapping(uint256 => mapping(address => bool)) public hasConfirmed;

    /// @notice Emitted when a signer proposes a new transfer.
    event TransferSubmitted(uint256 indexed proposalId, address indexed submitter, address indexed to, uint256 amount);
    /// @notice Emitted when a signer confirms a proposal.
    event TransferConfirmed(uint256 indexed proposalId, address indexed signer);
    /// @notice Emitted when a proposal is executed and the T42 are sent.
    event TransferExecuted(uint256 indexed proposalId, address indexed executor, address indexed to, uint256 amount);

    /// @dev The caller is not one of the two signers.
    error NotASigner(address caller);
    /// @dev A required address is the zero address.
    error ZeroAddress();
    /// @dev The same address was given twice as a signer.
    error DuplicateSigner(address signer);
    /// @dev No proposal has this id.
    error ProposalDoesNotExist(uint256 proposalId);
    /// @dev This signer has already confirmed this proposal.
    error AlreadyConfirmed(uint256 proposalId, address signer);
    /// @dev This proposal has already been executed.
    error AlreadyExecuted(uint256 proposalId);
    /// @dev The proposal does not have enough confirmations yet.
    error NotEnoughConfirmations(uint256 proposalId, uint256 confirmations, uint256 required);
    /// @dev The token contract reported a failed transfer.
    error TokenTransferFailed();

    /// @dev Stops the call unless the caller is a signer.
    modifier onlySigner() {
        if (!isSigner(msg.sender)) revert NotASigner(msg.sender);
        _;
    }

    /// @dev Stops the call unless the proposal exists and has not been executed yet.
    modifier pendingProposal(uint256 proposalId) {
        if (proposalId >= proposals.length) revert ProposalDoesNotExist(proposalId);
        if (proposals[proposalId].executed) revert AlreadyExecuted(proposalId);
        _;
    }

    /// @dev Sets the token and the two signers, once and for all.
    /// @param tokenAddress Address of the deployed Token42 contract.
    /// @param signer1Address First signer.
    /// @param signer2Address Second signer.
    constructor(address tokenAddress, address signer1Address, address signer2Address) {
        if (tokenAddress == address(0) || signer1Address == address(0) || signer2Address == address(0)) {
            revert ZeroAddress();
        }
        if (signer1Address == signer2Address) revert DuplicateSigner(signer1Address);

        token = IERC20(tokenAddress);
        signer1 = signer1Address;
        signer2 = signer2Address;
    }

    /// @notice Proposes to send `amount` T42 base units from this contract to `to`.
    /// @dev Submitting also counts as the submitter's own confirmation.
    /// @return proposalId The id of the new proposal.
    function submitTransfer(address to, uint256 amount) external onlySigner returns (uint256 proposalId) {
        if (to == address(0)) revert ZeroAddress();
        proposalId = proposals.length;
        proposals.push(Proposal({to: to, amount: amount, confirmationCount: 0, executed: false}));
        emit TransferSubmitted(proposalId, msg.sender, to, amount);
        _confirm(proposalId);
    }

    /// @notice Confirms a pending proposal (one confirmation per signer).
    function confirmTransfer(uint256 proposalId) external onlySigner pendingProposal(proposalId) {
        _confirm(proposalId);
    }

    /// @notice Sends the T42 of a proposal that has enough confirmations. Works only once.
    function executeTransfer(uint256 proposalId) external onlySigner pendingProposal(proposalId) {
        Proposal storage proposal = proposals[proposalId];
        if (proposal.confirmationCount < REQUIRED_CONFIRMATIONS) {
            revert NotEnoughConfirmations(proposalId, proposal.confirmationCount, REQUIRED_CONFIRMATIONS);
        }

        // Mark as executed before calling the token, so it can never run twice.
        proposal.executed = true;
        bool success = token.transfer(proposal.to, proposal.amount);
        if (!success) revert TokenTransferFailed();

        emit TransferExecuted(proposalId, msg.sender, proposal.to, proposal.amount);
    }

    /// @notice Returns true if `account` is one of the two signers.
    function isSigner(address account) public view returns (bool) {
        return account == signer1 || account == signer2;
    }

    /// @notice Returns how many proposals have been submitted.
    function proposalCount() external view returns (uint256) {
        return proposals.length;
    }

    /// @notice Returns how many T42 base units this multisig currently holds.
    function treasuryBalance() external view returns (uint256) {
        return token.balanceOf(address(this));
    }

    /// @dev Records the caller's confirmation of a proposal.
    function _confirm(uint256 proposalId) private {
        if (hasConfirmed[proposalId][msg.sender]) revert AlreadyConfirmed(proposalId, msg.sender);
        hasConfirmed[proposalId][msg.sender] = true;
        proposals[proposalId].confirmationCount += 1;
        emit TransferConfirmed(proposalId, msg.sender);
    }
}
