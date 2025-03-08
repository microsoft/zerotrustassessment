// src/theme/Layout.js
import React from 'react';
import OriginalLayout from '@theme-original/Layout';
import CookieConsent from '@site/src/components/Consent/CookieConsent';

export default function Layout(props) {
    return (
        <>
            <OriginalLayout {...props} />
            <CookieConsent />
        </>
    );
}
