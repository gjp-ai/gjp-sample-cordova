export function SectionTitle({ kicker, title, id, action }) {
    return (
        <div className="section-heading">
            <div>
                <p className="section-kicker">{kicker}</p>
                <h2 id={id}>{title}</h2>
            </div>
            {action && <button className="text-button" type="button">{action}</button>}
        </div>
    );
}
