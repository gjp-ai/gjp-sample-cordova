import { ArrowRight, Plus, ReceiptText, Repeat2, Send } from 'lucide-react';
import { SectionTitle } from '../../components/common/SectionTitle';
import { TransactionList } from '../../components/common/TransactionList';
import { transactions } from '../../data/mockData';
import { TAB_IDS } from '../../navigation/navigationConfig';

export function HomeView({ onNavigate }) {
    return (
        <div className="home-layout">
            <section className="balance-panel" aria-labelledby="balance-title">
                <div>
                    <p id="balance-title">Total available balance</p>
                    <strong>$23,280.76</strong>
                    <span>Across checking and savings</span>
                </div>
                <button type="button" onClick={() => onNavigate(TAB_IDS.accounts)}>
                    View accounts <ArrowRight size={17} />
                </button>
            </section>

            <section className="content-section" aria-labelledby="quick-actions-title">
                <SectionTitle kicker="Shortcuts" title="Quick actions" id="quick-actions-title" />
                <div className="quick-actions">
                    <ActionButton icon={Send} label="Send money" onClick={() => onNavigate(TAB_IDS.pay)} />
                    <ActionButton icon={Repeat2} label="Transfer" onClick={() => onNavigate(TAB_IDS.pay)} />
                    <ActionButton icon={ReceiptText} label="Pay a bill" onClick={() => onNavigate(TAB_IDS.pay)} />
                    <ActionButton icon={Plus} label="Add account" onClick={() => onNavigate(TAB_IDS.accounts)} />
                </div>
            </section>

            <section className="content-section activity-section" aria-labelledby="activity-title">
                <SectionTitle kicker="Latest" title="Recent activity" id="activity-title" action="View all" />
                <TransactionList items={transactions.slice(0, 3)} />
            </section>
        </div>
    );
}

function ActionButton({ icon: Icon, label, onClick }) {
    return (
        <button className="quick-action" type="button" onClick={onClick}>
            <span><Icon size={21} strokeWidth={2} /></span>
            {label}
        </button>
    );
}
