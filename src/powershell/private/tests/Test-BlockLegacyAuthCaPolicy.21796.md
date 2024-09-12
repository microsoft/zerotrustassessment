Legacy mechanisms such as basic authentication for SMTP and IMAP do not support modern security features like multifactor authentication (MFA), which is crucial for protecting against unauthorized access. This makes accounts using these protocols vulnerable to brute force, password spraying and similar password attacks, providing attackers with a means to gain initial access using stolen or guessed credentials.

Once an attacker successfully brute forces a password, they can use the compromised credentials to access the mailbox and other linked services, leveraging the weak authentication method as an entry point. Attackers who gain access through legacy authentication might establish persistence by configuring mail forwarding rules or other settings within Microsoft Exchange that allow them to maintain access to sensitive communications. Legacy authentication also provides a consistent method for attackers to reenter a system using the same credentials without triggering modern security alerts or requiring reauthentication.

From there, attackers can leverage legacy protocols to access other systems that are accessible via the compromised account, facilitating lateral movement.  Attackers using legacy protocols can blend in with legitimate user activities, making it difficult for security teams to distinguish between normal usage and malicious behavior.

#### Remediation action

Create a block legacy authentication conditional access policy and assign it to all users.

- [Block legacy authentication - Microsoft Learn](https://learn.microsoft.com/entra/identity/conditional-access/howto-conditional-access-policy-block-legacy#create-a-conditional-access-policy)

<!--- Results --->
%TestResult%
