import 'legal_page_screen.dart';

/// Real, first-version content for CareerOS AI's legal/info pages. Written
/// in plain language, grounded in what the app actually does (profile,
/// resume, ATS, salary, and AI-coach features backed by a JWT-authenticated
/// API) -- no invented certifications, compliance claims, or guarantees.
const String kLegalLastUpdated = 'September 2026';

const List<LegalSection> kPrivacyPolicySections = [
  LegalSection(
    '1. Introduction',
    'CareerOS AI ("CareerOS", "we", "us") is a career management app that helps you build a professional profile, generate resumes, analyze them against job descriptions, estimate market compensation, and get AI-assisted career guidance. This policy explains what information the app collects, how it is used, and the choices you have.',
  ),
  LegalSection(
    '2. Information We Collect',
    'We collect the information you provide directly when using CareerOS: account details, profile and career information, resume content, and the prompts and questions you send to the AI career coach. We do not collect information from third-party data brokers, and we do not require access to your contacts, camera, or location.',
  ),
  LegalSection(
    '3. Account Information',
    'When you register, we collect your name, email address, and a securely hashed password. Your email is used to identify your account and for essential account communication. We never store your password in plain text.',
  ),
  LegalSection(
    '4. Profile and Career Information',
    'To power the dashboard, resume builder, and AI recommendations, CareerOS stores the professional information you choose to add: headline, bio, location, current role, years of experience, education history, work experience, skills, certifications, languages, projects, and social/portfolio links.',
  ),
  LegalSection(
    '5. Resume Information',
    'Resumes you create in CareerOS -- including which of your profile sections you select to include in each one, the template chosen, and whether a resume is marked public -- are stored so you can edit, analyze, and share them later.',
  ),
  LegalSection(
    '6. AI Interactions',
    'When you use Career Coach, the ATS analyzer, or salary estimation, the relevant portions of your profile (such as your goal, skills, and experience) are sent to an AI processing provider to generate a response. We do not use your data to train third-party AI models beyond what is required to generate your requested response, and we do not sell your AI conversation history.',
  ),
  LegalSection(
    '7. How Information Is Used',
    'We use your information to operate the app\'s core features: rendering your dashboard and profile, generating and analyzing resumes, estimating salary ranges, producing AI career guidance, authenticating your account, and maintaining basic service reliability and security.',
  ),
  LegalSection(
    '8. How Information Is Stored',
    'Your data is stored in a managed database operated for CareerOS. Authentication uses industry-standard token-based sessions (JWT) with a limited lifetime. We apply reasonable technical safeguards, but no online service can guarantee absolute security.',
  ),
  LegalSection(
    '9. Security Practices',
    'Passwords are hashed, not stored in plain text. API access requires an authenticated session token. We limit which systems can access production data and review dependencies for known vulnerabilities. As with any product, you should use a strong, unique password and keep your device secure.',
  ),
  LegalSection(
    '10. Data Sharing',
    'We do not sell your personal information. We share data only with the service providers necessary to operate CareerOS (such as AI processing providers, described below) and only the data needed for that specific feature to function, or when required by law.',
  ),
  LegalSection(
    '11. Third-Party Services',
    'CareerOS uses third-party AI providers to power Career Coach, resume analysis, and salary estimation. These providers process the specific request you send (e.g., your stated goal, or the resume content you\'re analyzing) to generate a response; they do not receive your account credentials.',
  ),
  LegalSection(
    '12. AI Processing',
    'AI-generated content -- career assessments, roadmaps, ATS scores, and salary estimates -- is produced algorithmically and may be inaccurate or incomplete. It is offered as a starting point for your own judgment, not as professional financial, legal, or career advice.',
  ),
  LegalSection(
    '13. Your Choices',
    'You can review and edit your profile, education, experience, skills, projects, certifications, languages, and resumes at any time from within the app. You can also choose whether a resume is public or private.',
  ),
  LegalSection(
    '14. Account Deletion',
    'You may request deletion of your account and associated data by contacting support (see Contact Information below). We will process deletion requests within a reasonable time, subject to any data we are required to retain by law.',
  ),
  LegalSection(
    '15. Data Deletion Requests',
    'You may also request deletion of specific data -- for example, a single resume, ATS analysis, or salary estimate -- by removing it directly in the app, where that capability is available, or by contacting support.',
  ),
  LegalSection(
    '16. Data Retention',
    'We retain your account and profile data for as long as your account is active, so the app continues to function as expected. If you delete your account, we remove or anonymize your data within a reasonable period, except where retention is required for legal or security purposes.',
  ),
  LegalSection(
    '17. Children\'s Privacy',
    'CareerOS is intended for users who are old enough to participate in career planning (generally 16 years or older) and is not directed at young children. We do not knowingly collect information from children under 13.',
  ),
  LegalSection(
    '18. International Processing',
    'Depending on where our infrastructure and service providers are located, your information may be processed in a country other than the one you live in. We take reasonable steps to protect your information wherever it is processed.',
  ),
  LegalSection(
    '19. Changes to This Policy',
    'We may update this policy as CareerOS evolves. When we make material changes, we will update the "Last updated" date above and, where appropriate, notify you in the app.',
  ),
  LegalSection(
    '20. Contact Information',
    'Questions about this policy or your data can be sent to the support contact listed in Settings → Support.',
  ),
  LegalSection(
    '21. Effective Date',
    'This policy is effective as of the "Last updated" date shown at the top of this page.',
  ),
];

const List<LegalSection> kTermsOfServiceSections = [
  LegalSection(
    '1. Acceptance',
    'By creating an account or using CareerOS AI, you agree to these Terms of Service. If you do not agree, please do not use the app.',
  ),
  LegalSection(
    '2. Account Responsibilities',
    'You are responsible for maintaining the confidentiality of your account credentials and for all activity under your account. Provide accurate information when registering and keep your profile up to date.',
  ),
  LegalSection(
    '3. Acceptable Use',
    'You agree not to misuse CareerOS -- including attempting to access other users\' data, disrupt the service, reverse-engineer the app to bypass security, or submit unlawful, harassing, or fraudulent content.',
  ),
  LegalSection(
    '4. Career Guidance Disclaimer',
    'Career Coach, ATS analysis, and salary estimates are informational tools, not professional career counseling, legal, or financial advice. Decisions about your career and compensation are yours to make, informed by your own judgment.',
  ),
  LegalSection(
    '5. AI Limitations',
    'AI-generated responses can be incomplete, outdated, or incorrect. CareerOS does not guarantee the accuracy of any AI-generated assessment, roadmap, ATS score, or salary figure.',
  ),
  LegalSection(
    '6. Resume and Content Responsibility',
    'You are solely responsible for the accuracy of the information you enter, including resume content you generate, share, or mark public. Do not include false credentials or another person\'s information without authorization.',
  ),
  LegalSection(
    '7. Intellectual Property',
    'The CareerOS app, its design, and its underlying software are owned by CareerOS and its licensors. You retain ownership of the content you create (your profile and resume data).',
  ),
  LegalSection(
    '8. User-Generated Content',
    'By marking a resume "public," you authorize CareerOS to make that resume\'s content viewable through the corresponding public link or search surface, until you make it private again or delete it.',
  ),
  LegalSection(
    '9. Service Availability',
    'We aim to keep CareerOS available and reliable, but the service is provided on an "as available" basis. Features may be updated, changed, or occasionally unavailable due to maintenance or factors outside our control.',
  ),
  LegalSection(
    '10. Third-Party Services',
    'Certain features rely on third-party AI providers. We are not responsible for outages or errors originating from those third-party services, though we will work to route around them where possible.',
  ),
  LegalSection(
    '11. Suspension and Termination',
    'We may suspend or terminate access for accounts that violate these Terms. You may stop using CareerOS and request account deletion at any time.',
  ),
  LegalSection(
    '12. Disclaimers',
    'CareerOS is provided "as is" without warranties of any kind, express or implied, including fitness for a particular purpose. We do not guarantee that using CareerOS will result in a job offer, salary increase, or any particular career outcome.',
  ),
  LegalSection(
    '13. Limitation of Liability',
    'To the fullest extent permitted by law, CareerOS and its team are not liable for indirect, incidental, or consequential damages arising from your use of the app, including decisions made based on AI-generated content.',
  ),
  LegalSection(
    '14. Changes to These Terms',
    'We may update these Terms as the product evolves. Continued use of CareerOS after an update constitutes acceptance of the revised Terms.',
  ),
  LegalSection(
    '15. Governing Law',
    'These Terms are governed by the laws of the jurisdiction in which CareerOS is operated, without regard to conflict-of-law principles, to the extent permitted by applicable local law.',
  ),
  LegalSection(
    '16. Contact',
    'Questions about these Terms can be sent to the support contact listed in Settings → Support.',
  ),
];

const String kAboutIntro =
    'CareerOS AI is your personal career operating system -- one place to build your professional profile, craft resumes, understand how they perform against real job descriptions, benchmark your compensation, and get AI-assisted guidance on your next career move.';

const List<LegalSection> kAboutSections = [
  LegalSection(
    'What CareerOS Does',
    'Dashboard gives you a snapshot of your career health and next best actions. Profile and Resume Studio turn your experience, education, skills, and projects into polished, tailorable resumes. ATS Analyzer scores a resume against a target role. Salary Intelligence estimates and compares market compensation. Career AI acts as a copilot for career decisions -- goals, skill gaps, and roadmaps.',
  ),
  LegalSection(
    'How AI Is Used',
    'CareerOS routes AI requests to one of several language model providers to generate career assessments, roadmaps, ATS analysis, and salary estimates grounded in the real profile data you\'ve entered -- never fabricated placeholder content.',
  ),
  LegalSection(
    'Version',
    'CareerOS AI v1.0.0.',
  ),
];
