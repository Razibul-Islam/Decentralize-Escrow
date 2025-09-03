# Decentralized Escrow Smart Contract Documentation

## 📌 Overview

The Escrow Smart Contract provides a trustless payment solution for freelance work and peer-to-peer transactions.  
It ensures that funds are securely locked until project conditions are met, reducing the risk of fraud or non-payment.

- **Clients** deposit funds into escrow.
- **Freelancers** receive payment once the client confirms delivery or after an auto-release time-lock.
- **Disputes** can optionally be resolved by an arbitrator (owner or DAO).

---

## 🚀 Features

- **Secure Escrow Payments:** Supports ETH or ERC20 deposits.
- **Two-Party Workflow:** Client deposits → Freelancer delivers → Client confirms → Funds released.
- **Auto-Release:** If the client doesn’t respond before the deadline, payment is auto-released to the freelancer.
- **Dispute Handling:** Owner/DAO can resolve disputes by releasing funds to either party.
- **Platform Fee:** Percentage fee for platform sustainability.
- **Reentrancy Protection:** Secure withdrawals.

---

## 🔧 Contract Architecture

### State Variables

```solidity
struct Escrow {
    address client;         // The payer who creates the escrow
    address freelancer;     // The receiver who will be paid
    uint256 amount;         // Escrowed amount
    IERC20 token;           // ERC20 token address (or address(0) for ETH)
    uint256 deadline;       // Timestamp for auto-release
    bool released;          // Whether escrow is already resolved
    bool disputed;          // Whether escrow is in dispute
}
```

- `mapping(uint256 => Escrow)` — Tracks escrows by ID
- `uint256 public escrowCount` — Incremental counter for new escrows
- `uint16 public platformFeeBps` — Platform fee in basis points (1% = 100)
- `address public platformWallet` — Fee receiver
- `address public arbitrator` — Address responsible for dispute resolution

---

## ⚙️ Functions

### Escrow Lifecycle

- `createEscrow(address freelancer, IERC20 token, uint256 amount, uint256 duration)`  
  Client deposits ETH or ERC20 into escrow.

- `releaseEscrow(uint256 escrowId)`  
  Client confirms completion; funds are released.

- `autoRelease(uint256 escrowId)`  
  Anyone can call after the deadline; funds are released to the freelancer.

### Dispute Handling

- `raiseDispute(uint256 escrowId)`  
  Client or freelancer marks escrow as disputed.

- `resolveDispute(uint256 escrowId, bool favorFreelancer)`  
  Arbitrator resolves the dispute.

### Platform Management

- `withdrawFees()`  
  Platform wallet withdraws accumulated fees.

- `setPlatformFee(uint16 newFee)`
- `setPlatformWallet(address newWallet)`
- `setArbitrator(address newArbitrator)`

---

## 📢 Events

- `EscrowCreated(uint256 indexed id, address indexed client, address indexed freelancer, uint256 amount, address token, uint256 deadline)`
- `EscrowReleased(uint256 indexed id, address indexed freelancer, uint256 amount)`
- `EscrowDisputed(uint256 indexed id)`
- `EscrowResolved(uint256 indexed id, address winner, uint256 amount)`
- `FeeWithdrawn(address indexed to, uint256 amount)`

---

## 🛠 Example Workflow

### Standard Flow

1. Client calls `createEscrow()` and deposits funds.
2. Freelancer delivers work.
3. Client calls `releaseEscrow()`; freelancer gets paid.

### Auto-Release Flow

1. Client creates escrow with a 7-day deadline.
2. Freelancer delivers work.
3. Client does not confirm.
4. After 7 days, anyone can call `autoRelease()`; freelancer gets paid.

### Dispute Flow

1. Client or freelancer calls `raiseDispute()`.
2. Arbitrator investigates off-chain.
3. Arbitrator calls `resolveDispute()`; funds go to the winner.

---

## 🔒 Security Considerations

- Use `ReentrancyGuard` for fund releases.
- Validate that ETH amount matches the required deposit.
- Ensure escrow cannot be released more than once.
- Dispute resolution only callable by the arbitrator.
- Platform fees are capped (e.g., max 10%).

---

## 📚 Potential Extensions

- NFT escrow (escrow NFT ownership until conditions are met)
- Multi-signature approval (both parties must sign release)
- Partial payments (milestone-based escrow)
- DAO-governed arbitration