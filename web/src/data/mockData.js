import {
    ArrowDownLeft,
    ArrowUpRight,
    Bell,
    Building2,
    CircleHelp,
    CreditCard,
    FileText,
    Fingerprint,
    Landmark,
    ReceiptText,
    Settings,
    UserRound
} from 'lucide-react';

export const accounts = Object.freeze([
    { name: 'Everyday Checking', number: '2841', balance: '$8,420.56', icon: Landmark, tone: 'blue' },
    { name: 'Goal Savings', number: '9017', balance: '$14,860.20', icon: Building2, tone: 'green' },
    { name: 'Rewards Card', number: '4432', balance: '$1,284.09', meta: '$3,715.91 available', icon: CreditCard, tone: 'amber' }
]);

export const transactions = Object.freeze([
    { name: 'Salary deposit', date: 'Today', amount: '+$3,850.00', icon: ArrowDownLeft, tone: 'positive' },
    { name: 'Green Market', date: 'Yesterday', amount: '-$64.28', icon: ReceiptText, tone: 'neutral' },
    { name: 'City Utilities', date: 'Jul 14', amount: '-$128.40', icon: FileText, tone: 'neutral' },
    { name: 'Savings transfer', date: 'Jul 12', amount: '-$500.00', icon: ArrowUpRight, tone: 'transfer' }
]);

export const recipients = Object.freeze([
    { name: 'Alex', initials: 'AL', tone: 'cyan' },
    { name: 'Morgan', initials: 'MO', tone: 'green' },
    { name: 'Taylor', initials: 'TA', tone: 'amber' },
    { name: 'Jordan', initials: 'JO', tone: 'rose' }
]);

export const moreMenuItems = Object.freeze([
    { label: 'Profile and personal details', icon: UserRound },
    { label: 'Security and sign-in', icon: Fingerprint },
    { label: 'Notifications', icon: Bell },
    { label: 'App settings', icon: Settings },
    { label: 'Help and support', icon: CircleHelp }
]);
