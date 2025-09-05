# Decentralized Escrow Smart Contract Documentation

## 📌 Overview

The Decentralized Escrow Smart Contract enables secure, trustless payments for freelance and peer-to-peer transactions.  
Funds are locked until project conditions are met, minimizing fraud and non-payment risks.

- **Clients** deposit ETH or ERC20 tokens into escrow.
- **Freelancers** receive payment after client confirmation or auto-release.
- **Disputes** can be resolved by an arbitrator (owner or DAO).

---

## 🚀 Features

- **Supports ETH & ERC20:** Accepts both native ETH and ERC20 tokens.
- **Two-Party Workflow:** Client deposits → Freelancer delivers → Client confirms → Funds released.
- **Auto-Release:** If the client is inactive past the deadline, funds auto-release to the freelancer.
- **Dispute Resolution:** Arbitrator can resolve disputes and release funds to either party.
- **Platform Fee:** A configurable percentage fee is deducted for platform sustainability.
- **Reentrancy Protection:** Secure withdrawals using `ReentrancyGuard`.

---

## 🔧 Contract Architecture

### State Variables

```solidity
struct Escrow {
    address client;         // Payer
    address freelancer;     // Payee
    uint256 amount;         // Amount in escrow
    uint256 deadline;       // Auto-release timestamp
    bool released;          // True if escrow resolved
    bool disputed;          // True if in dispute
}
```

- `mapping(uint256 => Escrow) public escrows;` — Escrows by ID
- `uint256 public escrowCount;` — Escrow counter
- `uint16 public platformFeeBps;` — Platform fee (basis points)
- `address public platformWallet;` — Fee receiver
- `address public arbitrator;` — Dispute resolver

---

## ⚙️ Functions

### Escrow Lifecycle

- `function createEscrow(address freelancer, IERC20 token, uint256 amount, uint256 duration) external payable`  
  Client deposits ETH or ERC20 tokens into escrow.

- `function releaseEscrow(uint256 escrowId) external`  
  Client confirms completion; funds released to freelancer.

- `function autoRelease(uint256 escrowId) external`  
  Anyone can call after deadline; funds released to freelancer.

### Dispute Handling

- `function raiseDispute(uint256 escrowId) external`  
  Client or freelancer marks escrow as disputed.

- `function resolveDispute(uint256 escrowId, bool favorFreelancer) external`  
  Arbitrator resolves dispute, releasing funds to winner.

### Platform Management

- `function withdrawFees() external`  
  Platform wallet withdraws accumulated fees.

- `function setPlatformFee(uint16 newFee) external`
- `function setPlatformWallet(address newWallet) external`
- `function setArbitrator(address newArbitrator) external`

---

## 📢 Events

- `event EscrowCreated(uint256 indexed id, address indexed client, address indexed freelancer, uint256 amount, address token, uint256 deadline);`
- `event EscrowReleased(uint256 indexed id, address indexed freelancer, uint256 amount);`
- `event EscrowDisputed(uint256 indexed id);`
- `event EscrowResolved(uint256 indexed id, address winner, uint256 amount);`
- `event FeeWithdrawn(address indexed to, uint256 amount);`

---

## 🛠 Example Workflow

### Standard Flow

1. Client calls `createEscrow()` and deposits funds.
2. Freelancer delivers work.
3. Client calls `releaseEscrow()`; freelancer receives payment.

### Auto-Release Flow

1. Client creates escrow with a deadline.
2. Freelancer delivers work.
3. Client does not confirm.
4. After deadline, anyone calls `autoRelease()`; freelancer receives payment.

### Dispute Flow

1. Client or freelancer calls `raiseDispute()`.
2. Arbitrator investigates off-chain.
3. Arbitrator calls `resolveDispute()`; funds released to winner.

---

## 🔒 Security Considerations

- Uses `ReentrancyGuard` for fund releases.
- Validates ETH deposit matches required amount.
- Prevents double release of escrow.
- Only arbitrator can resolve disputes.
- Platform fees are capped (e.g., max 10%).

---

## 📚 Potential Extensions

- NFT escrow (escrow NFT ownership until conditions met)
- Multi-signature approval (both parties sign release)
- Partial payments (milestone-based escrow)
- DAO-