# Contract System Summary

## Overview
The contract system for 4iDeas now includes comprehensive contract management with pricing, payment scheduling, and progress reporting.

## Contract Structure

### Financial Terms
1. **Final Price** - Total project cost
2. **Down Payment** - Initial payment upon contract signing
3. **Weekly Payments** - Payments triggered after admin progress reports
4. **Final Payment** - Remaining balance after down payment and weekly payments

### Payment Flow
```
Contract Sent → Contract Signed → Down Payment → Progress Reports → Weekly Payments → Final Payment
```

## Features Implemented

### 1. Admin Contract Creation
- Admin can create contracts with:
  - Final price
  - Down payment amount
  - Weekly payment amount
  - Contract notes
- System automatically calculates:
  - Number of weeks
  - Total weekly payments
  - Final payment amount

### 2. Contract View Screen
- Full contract display with:
  - Parties (Service Provider & Client)
  - Project details
  - Financial terms breakdown
  - Payment schedule
  - Terms and conditions
  - Signatures section

### 3. Payment System
- **Down Payment**: One-time payment after contract signing
- **Weekly Payments**: Triggered after admin submits progress reports
- **Payment Tracking**: Total paid amount tracked

### 4. Progress Reports (Future Implementation)
- Admin can submit progress reports
- Each report triggers a weekly payment
- Reports include:
  - Title
  - Description
  - Week number
  - Milestone
  - Completion percentage

## Database Fields (Firestore)

### Contract Fields
- `contractSent` (boolean)
- `contractSentDate` (timestamp)
- `contractSentBy` (email)
- `contractSigned` (boolean)
- `contractSignedDate` (timestamp)
- `contractSignedBy` (user ID)
- `contractUrl` (string, optional)
- `contractNotes` (string, optional)

### Pricing Fields
- `finalPrice` (number)
- `downPaymentAmount` (number)
- `weeklyPaymentAmount` (number)
- `numberOfWeeks` (number)
- `totalWeeklyPayments` (number)
- `finalPaymentAmount` (number)

### Payment Fields
- `downPaymentPaid` (boolean)
- `downPaymentDate` (timestamp)
- `downPaymentPaidBy` (user ID)
- `totalPaidAmount` (number)
- `weeklyPaymentsMade` (number)
- `paymentMethod` (string)
- `transactionId` (string)
- `paymentNotes` (string)

### Progress Report Fields
- `progressReports` (array of maps)
- `latestProgressReport` (map)
- Each report contains:
  - `reportId` (string)
  - `title` (string)
  - `description` (string)
  - `weekNumber` (number)
  - `milestone` (string)
  - `completionPercentage` (number)
  - `createdBy` (email)
  - `createdAt` (timestamp)
  - `paymentTriggered` (boolean)

## User Flows

### Admin Flow
1. View client order
2. Send response to client
3. After agreement, create contract with pricing
4. Send contract to client
5. Submit weekly progress reports
6. Track payments received

### Client Flow
1. Receive contract from admin
2. View full contract details
3. Sign contract
4. Make down payment
5. Receive progress reports
6. Make weekly payments after reports
7. Make final payment upon completion

## Files Created/Modified

### New Files
- `CONTRACT_TEMPLATE.md` - Contract template documentation
- `lib/features/contract/presentation/screens/contract_view_screen.dart` - Contract display screen

### Modified Files
- `lib/services/order_service.dart` - Added contract and payment methods
- `lib/features/admin/presentation/screens/admin_order_detail_screen.dart` - Added contract creation form
- `lib/features/auth/presentation/screens/profile_screen.dart` - Added contract view link

## Next Steps (To Complete Full Implementation)

1. **Progress Report UI** - Create admin screen for submitting progress reports
2. **Weekly Payment UI** - Update payment screen to handle weekly payments triggered by reports
3. **Payment Gateway Integration** - Integrate with Stripe/PayPal for actual payment processing
4. **Email Notifications** - Send emails when contracts are sent, signed, or payments are due
5. **PDF Generation** - Generate downloadable PDF contracts
6. **Digital Signatures** - Implement proper digital signature functionality

