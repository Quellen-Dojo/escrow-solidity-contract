// SPDX-License-Identifier: MiT
pragma solidity >0.6.0;

contract Escrow {
    enum State {BUYER_DEPOSITED, SELLER_DELIVERED, BUYER_CONFIRMED, DONE}
    address payable public buyer;
    address payable public seller;
    uint256 contractedAmount;
    State public currentState;

    modifier onlyBuyer() {
        require(tx.origin == buyer || tx.origin == address(this), "Only the payer can call this method!");
        _;
    }

    modifier onlySeller() {
        require(tx.origin == seller || tx.origin == address(this), "Only the service provider can call this method!");
        _;
    }

    modifier eitherBuyerOrSeller() {
        require(tx.origin == seller || tx.origin == buyer || tx.origin == address(this), "Only the two participating parties, or the owner of this Escrow can initiate this function!");
        _;
    }

    function getContractedAmount() external view returns (uint256) {
        return contractedAmount;
    }

    function getSeller() external view returns (address payable) {
        return seller;
    }

    function getBuyer() external view returns (address) {
        return buyer;
    }

    function getState() external view returns (State) {
        return currentState;
    }

    function prematurelyCancel() eitherBuyerOrSeller external {
        require(currentState == State.BUYER_DEPOSITED,"You cannot cancel this contract after the service provider has confirmed sending of product");
        buyer.transfer(contractedAmount);
        currentState = State.DONE;
    }

    function declarePerformedService() onlySeller external {
        require(currentState == State.BUYER_DEPOSITED,"Service provider cannot reconfirm sent product/service at this time!");
        currentState = State.SELLER_DELIVERED;
    }

    function declareReceivedService() onlyBuyer external {
        require(currentState == State.SELLER_DELIVERED, "Service provider has not confirmed that they have performed service/sent product!");
        currentState = State.BUYER_CONFIRMED;
        seller.transfer(contractedAmount);
        currentState = State.DONE;
    }

    constructor(address payable _seller) payable {
        require(msg.value > 0,"Send more than 0 WEI to initiate the escrow contract!");
        buyer = payable(msg.sender);
        seller = _seller;
        contractedAmount = msg.value;
        currentState = State.BUYER_DEPOSITED;
    }
}

contract EscrowManager {
    uint256 private escrowIndex;
    mapping(uint256 => Escrow) private allEscrows;

    // Initiates an Escrow and returns the index as the user's id to use for future calls
    function initiateEscrow(address payable sellerAddress) external payable returns (uint256) {
        Escrow newEscrow = new Escrow{value: msg.value}(sellerAddress);
        allEscrows[escrowIndex] = newEscrow;
        escrowIndex += 1;
        return escrowIndex - 1;
    }

    function callPrematurelyCancel(uint256 index) external {
        allEscrows[index].prematurelyCancel();
    }

    function callDeclarePerformedService(uint256 index) external {
        allEscrows[index].declarePerformedService();
    }

    function callDeclareReceivedService(uint256 index) external {
        allEscrows[index].declareReceivedService();
    }

    constructor() {
        escrowIndex = 0;
    }
}