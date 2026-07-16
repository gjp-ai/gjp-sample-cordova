import { ChevronRight, Plus, ReceiptText, Repeat2, Send, ShieldCheck, Smartphone } from 'lucide-react';
import { SectionTitle } from '../../components/common/SectionTitle';
import { recipients } from '../../data/mockData';

const paymentActions = Object.freeze([
    { icon: Send, title: 'Send money', detail: 'Pay a person', tone: 'cyan' },
    { icon: Repeat2, title: 'Transfer', detail: 'Between accounts', tone: 'green' },
    { icon: ReceiptText, title: 'Pay bills', detail: 'Manage billers', tone: 'amber' },
    { icon: Smartphone, title: 'Mobile top up', detail: 'Recharge a phone', tone: 'rose' }
]);

export function PayView() {
    return (
        <div className="pay-layout">
            <section className="content-section" aria-labelledby="move-money-title">
                <SectionTitle kicker="Choose an action" title="Move money" id="move-money-title" />
                <div className="payment-actions">
                    {paymentActions.map((action) => <PaymentAction key={action.title} {...action} />)}
                </div>
            </section>

            <section className="content-section" aria-labelledby="recipients-title">
                <div className="section-heading">
                    <div><p className="section-kicker">Send again</p><h2 id="recipients-title">Recent recipients</h2></div>
                    <button className="icon-button bordered" type="button" aria-label="Add recipient"><Plus size={20} /></button>
                </div>
                <div className="recipient-list">
                    {recipients.map(({ name, initials, tone }) => (
                        <button type="button" className="recipient" key={name}>
                            <span className={`recipient-avatar ${tone}`}>{initials}</span>
                            <span>{name}</span>
                        </button>
                    ))}
                </div>
            </section>

            <section className="transfer-note" aria-label="Transfer status">
                <span><ShieldCheck size={22} /></span>
                <div><strong>Transfers are protected</strong><p>Security checks run before every payment.</p></div>
            </section>
        </div>
    );
}

function PaymentAction({ icon: Icon, title, detail, tone }) {
    return (
        <button className="payment-action" type="button">
            <span className={`payment-icon ${tone}`}><Icon size={23} /></span>
            <span><strong>{title}</strong><small>{detail}</small></span>
            <ChevronRight size={19} />
        </button>
    );
}
