// src/components/CookieConsent.js
import React, { useState, useEffect } from 'react';
import Cookies from 'js-cookie';

const CookieConsent = () => {
    const [isVisible, setIsVisible] = useState(false);

    useEffect(() => {
        const consent = Cookies.get('cookie-consent');
        if (!consent) {
            setIsVisible(true);
        }
    }, []);

    const handleConsent = (consent) => {
        Cookies.set('cookie-consent', consent, { expires: 365 });
        if (consent === 'accepted') {
            console.debug("accepted cookie");
            window.clarity && window.clarity('consent');        //accept
        } else {
            console.debug("declined cookie");
            window.clarity && window.clarity('consent', false); //decline
        }
        setIsVisible(false);
    };

    return (
        isVisible && (
            <div style={styles.container}>
                <div style={styles.content}>
                    <div style={styles.text}>
                        <h3>We value your privacy</h3>
                        <p>
                            We use cookies to analyze how you use our site. This helps us improve your experience and provide better services. You can choose to accept or reject the use of cookies.
                        </p>
                    </div>
                    <div style={styles.buttons}>
                        <button style={styles.rejectbutton} onClick={() => handleConsent('declined')}>
                            Reject All
                        </button>
                        <button style={styles.button} onClick={() => handleConsent('accepted')}>
                            Accept All
                        </button>
                    </div>
                </div>
            </div>
        )
    );
};

const styles = {
    container: {
        position: 'fixed',
        bottom: 0,
        left: 0,
        width: '100%',
        height: '15vh',
        maxHeight: '15%',
        backgroundColor: '#ffffff',
        boxShadow: '0px -2px 5px rgba(0, 0, 0, 0.1)',
        zIndex: 1000,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
    },
    content: {
        width: '90%',
        maxWidth: '1200px',
        display: 'flex',
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
    },
    text: {
        margin: 0,
        fontSize: '1rem',
        color: '#333',
    },
    buttons: {
        display: 'flex',
        gap: '10px',
    },
    button: {
        padding: '8px 16px',
        fontSize: '0.9rem',
        color: '#ffffff',
        backgroundColor: '#0078d4',
        border: 'none',
        borderRadius: '5px',
        cursor: 'pointer',
    },
    rejectbutton: {
        padding: '8px 16px',
        fontSize: '0.9rem',
        color: '#000000',
        backgroundColor: '#ffffff',
        border: 'solid',
        borderRadius: '5px',
        cursor: 'pointer',
    },
};

export default CookieConsent;
