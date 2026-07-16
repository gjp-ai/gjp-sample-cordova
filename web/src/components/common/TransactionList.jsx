export function TransactionList({ items }) {
    return (
        <div className="transaction-list">
            {items.map(({ name, date, amount, icon: Icon, tone }) => (
                <div className="transaction-row" key={`${name}-${date}`}>
                    <span className={`transaction-icon ${tone}`}><Icon size={19} /></span>
                    <span className="transaction-name"><strong>{name}</strong><span>{date}</span></span>
                    <strong className={tone === 'positive' ? 'positive-amount' : ''}>{amount}</strong>
                </div>
            ))}
        </div>
    );
}
