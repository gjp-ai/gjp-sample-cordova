import { ChevronRight, Plus } from 'lucide-react';
import { SectionTitle } from '../../components/common/SectionTitle';
import { TransactionList } from '../../components/common/TransactionList';
import { accounts, transactions } from '../../data/mockData';

export function AccountsView() {
    return (
        <div className="accounts-layout">
            <section className="account-summary" aria-label="Account summary">
                <div><span>Assets</span><strong>$23,280.76</strong></div>
                <div><span>Credit balance</span><strong>$1,284.09</strong></div>
            </section>
            <section className="content-section" aria-labelledby="accounts-title">
                <div className="section-heading">
                    <div><p className="section-kicker">Overview</p><h2 id="accounts-title">Your accounts</h2></div>
                    <button className="icon-button bordered" type="button" aria-label="Add account"><Plus size={20} /></button>
                </div>
                <div className="account-list">
                    {accounts.map(({ name, number, balance, meta, icon: Icon, tone }) => (
                        <button className="account-row" type="button" key={number}>
                            <span className={`account-icon ${tone}`}><Icon size={22} /></span>
                            <span className="account-name"><strong>{name}</strong><span>**** {number}</span></span>
                            <span className="account-balance"><strong>{balance}</strong>{meta && <span>{meta}</span>}</span>
                            <ChevronRight size={19} className="row-chevron" />
                        </button>
                    ))}
                </div>
            </section>
            <section className="content-section" aria-labelledby="account-activity-title">
                <SectionTitle kicker="All accounts" title="Recent activity" id="account-activity-title" />
                <TransactionList items={transactions} />
            </section>
        </div>
    );
}
