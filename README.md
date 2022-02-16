# Solidity Escrow Contract

Can be deployed on EVM-compatible blockchains. Creates and manages escrow processes where sellers and buyers of services or goods can confidently conduct transactions. A controlling party can deploy the `EscrowManager` contract once and then run an escrow service. A single transaction can also be handled by just deploying the `Escrow` class.



## Process of a single `Escrow` contract

1. Buyer deploys the `Escrow` contract themselves or calls `initiateEscrow(SELLER_ADDRESS)` on an `EscrowManager`. Either way, the agreed amount is sent with this transaction and held by the contract. The contract can be cancelled by calling `prematurelyCancel()`. Initiating the contract through an `EscrowManager` returns an id that both parties may use to interact with a single Escrow, or multiple, if they have the ids for them and are authorized to do so.

2. The Seller calls `declarePerformedService()` once they have performed the service, or shipped/delivered the good and awaits the buyer confirmation. The contract cannot be cancelled after this point, except by the contract owner.

3. Buyer calls `declareReceivedService()` and funds are transferred to the seller, completing the transaction.