# VelocityShares (VELS)

A sophisticated dividend-distributing token built on the Stacks blockchain, designed to accelerate wealth distribution among token holders through systematic yield redistribution.

## Overview

VelocityShares introduces a revolutionary approach to tokenized yield distribution, enabling seamless STX dividend payouts to token holders based on their proportional ownership. The protocol implements epoch-based distribution cycles that ensure fair and transparent yield allocation across all participants.

## Key Features

### **Accelerated Yield Distribution**
- Automated STX dividend distribution to all token holders
- Proportional yield allocation based on token ownership
- Epoch-based distribution cycles for systematic payouts

### **Transparent Economics**
- Real-time yield pool tracking
- Claimable yield calculations per participant
- Historical claim verification and tracking

### **Secure Architecture**
- SIP-010 compliant fungible token standard
- Owner-controlled yield deposits and distributions
- Emergency withdrawal mechanisms for protocol safety

### **Efficient Operations**
- Gas-optimized claim mechanisms
- Batch distribution capabilities
- Minimal transaction overhead for participants

## Smart Contract Functions

### Core Token Operations
- `mint(amount, recipient)` - Issue new VELS tokens
- `burn(amount, from)` - Remove tokens from circulation
- `transfer(amount, from, to, memo)` - Standard token transfers

### Yield Management
- `deposit-yield(amount)` - Add STX to the yield pool
- `distribute-yield()` - Initialize new distribution epoch
- `claim-yield()` - Claim available yield rewards
- `get-claimable-yield(user)` - Calculate pending yields

### Information Queries
- `get-yield-pool()` - Current undistributed yield amount
- `get-yield-per-token()` - Yield rate per token unit
- `get-distribution-epoch()` - Current distribution cycle
- `has-claimed-epoch(user, epoch)` - Verify claim status

## Technical Specifications

- **Token Symbol**: VELS
- **Decimals**: 6
- **Standard**: SIP-010 Fungible Token
- **Platform**: Stacks Blockchain
- **Language**: Clarity Smart Contract

## Distribution Mechanics

1. **Yield Deposit**: Protocol owner deposits STX to the yield pool
2. **Distribution Trigger**: Owner initiates yield distribution across all holders
3. **Epoch Creation**: New distribution epoch begins with calculated yield-per-token rate
4. **Participant Claims**: Token holders claim their proportional yield rewards
5. **Automatic Tracking**: System prevents double-claiming and maintains historical records

## Getting Started

### Prerequisites
- Stacks wallet with STX balance
- Access to Stacks blockchain testnet or mainnet
- Clarity development environment (for deployment)

### Deployment
```bash
# Clone the repository
git clone https://github.com/peacebas/VelocityShares.git

# Navigate to project directory
cd VelocityShares

# Deploy to Stacks blockchain
clarinet deploy
```

### Usage Example
```clarity
;; Claim available yield rewards
(contract-call? .velocityshares claim-yield)

;; Check your claimable yield
(contract-call? .velocityshares get-claimable-yield 'YOUR-PRINCIPAL-ADDRESS)
```

## Security Considerations

- Only contract owner can deposit yield and trigger distributions
- Emergency withdrawal function available for protocol recovery
- Comprehensive error handling prevents invalid operations
- Claim verification prevents double-spending of yield rewards

## Contributing

We welcome contributions to improve VelocityShares. Please submit pull requests with detailed descriptions of changes and comprehensive test coverage.
