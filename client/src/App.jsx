import { Routes, Route } from 'react-router-dom';
import ProtectedRoute from './components/ProtectedRoute';

import Home from './pages/public/Home';
import Explore from './pages/public/Explore';
import CampaignDetail from './pages/public/CampaignDetail';
import HowItWorks from './pages/public/HowItWorks';
import Safety from './pages/public/Safety';
import Contact from './pages/public/Contact';
import HelpCenter from './pages/public/HelpCenter';
import { Terms, Privacy } from './pages/public/Legal';

import Login from './pages/auth/Login';
import Register from './pages/auth/Register';
import CheckEmail from './pages/auth/CheckEmail';

import DonorDashboard from './pages/donor/Dashboard';
import Donate from './pages/donor/Donate';
import DonationConfirmed from './pages/donor/DonationConfirmed';
import SavedCampaigns from './pages/donor/SavedCampaigns';
import FollowedCampaigns from './pages/donor/FollowedCampaigns';
import DonorNotifications from './pages/donor/Notifications';
import DonorSettings from './pages/donor/Settings';

import OrganizerOnboard from './pages/organizer/Onboard';
import OrganizerDashboard from './pages/organizer/Dashboard';
import CreateCampaignBasics from './pages/organizer/CreateCampaignBasics';
import CreateCampaignStory from './pages/organizer/CreateCampaignStory';
import CreateCampaignReview from './pages/organizer/CreateCampaignReview';
import EditCampaign from './pages/organizer/EditCampaign';
import Analytics from './pages/organizer/Analytics';
import Withdrawals from './pages/organizer/Withdrawals';
import Team from './pages/organizer/Team';
import Invites from './pages/organizer/Invites';

import Verification from './pages/beneficiary/Verification';

import MyTickets from './pages/support/MyTickets';

import AdminOverview from './pages/admin/Overview';
import AdminCampaigns from './pages/admin/Campaigns';
import AdminDonations from './pages/admin/Donations';
import VerificationQueue from './pages/admin/VerificationQueue';
import UserManagement from './pages/admin/UserManagement';
import AdminReports from './pages/admin/Reports';
import FraudRisk from './pages/admin/FraudRisk';
import SupportTickets from './pages/admin/SupportTickets';
import AuditLogs from './pages/admin/AuditLogs';

export default function App() {
  return (
    <Routes>
      {/* Public */}
      <Route path="/" element={<Home />} />
      <Route path="/explore" element={<Explore />} />
      <Route path="/campaigns/:id" element={<CampaignDetail />} />
      <Route path="/how-it-works" element={<HowItWorks />} />
      <Route path="/safety" element={<Safety />} />
      <Route path="/contact" element={<Contact />} />
      <Route path="/help" element={<HelpCenter />} />
      <Route path="/terms" element={<Terms />} />
      <Route path="/privacy" element={<Privacy />} />

      {/* Auth */}
      <Route path="/login" element={<Login />} />
      <Route path="/register" element={<Register />} />
      <Route path="/check-email" element={<ProtectedRoute allowUnverified><CheckEmail /></ProtectedRoute>} />

      {/* Donor */}
      <Route path="/donor" element={<ProtectedRoute><DonorDashboard /></ProtectedRoute>} />
      <Route path="/donor/saved" element={<ProtectedRoute><SavedCampaigns /></ProtectedRoute>} />
      <Route path="/donor/followed" element={<ProtectedRoute><FollowedCampaigns /></ProtectedRoute>} />
      <Route path="/donor/notifications" element={<ProtectedRoute><DonorNotifications /></ProtectedRoute>} />
      <Route path="/donor/settings" element={<ProtectedRoute><DonorSettings /></ProtectedRoute>} />
      <Route path="/donate/:id" element={<Donate />} />
      <Route path="/donate/:id/confirmed" element={<DonationConfirmed />} />

      {/* Organizer */}
      <Route path="/organizer/onboard" element={<ProtectedRoute><OrganizerOnboard /></ProtectedRoute>} />
      <Route path="/organizer/invites" element={<ProtectedRoute><Invites /></ProtectedRoute>} />
      <Route path="/support" element={<ProtectedRoute><MyTickets /></ProtectedRoute>} />
      {/* Dashboard and Analytics show owned + co-organized campaigns
          (server-scoped by CampaignMember, not by global role) — a
          co-organizer whose global role is still 'donor' must be able to
          reach these. Campaign creation and Team/Withdrawals stay
          organizer-role-gated below (owner-only actions). */}
      <Route path="/organizer" element={<ProtectedRoute><OrganizerDashboard /></ProtectedRoute>} />
      <Route path="/organizer/analytics" element={<ProtectedRoute><Analytics /></ProtectedRoute>} />
      <Route path="/organizer/campaigns/:id/edit" element={<ProtectedRoute><EditCampaign /></ProtectedRoute>} />
      <Route path="/organizer/new/basics" element={<ProtectedRoute roles={['organizer', 'admin']}><CreateCampaignBasics /></ProtectedRoute>} />
      <Route path="/organizer/new/story" element={<ProtectedRoute roles={['organizer', 'admin']}><CreateCampaignStory /></ProtectedRoute>} />
      <Route path="/organizer/new/review" element={<ProtectedRoute roles={['organizer', 'admin']}><CreateCampaignReview /></ProtectedRoute>} />
      <Route path="/organizer/team" element={<ProtectedRoute roles={['organizer', 'admin']}><Team /></ProtectedRoute>} />
      <Route path="/organizer/withdrawals" element={<ProtectedRoute roles={['organizer', 'admin']}><Withdrawals /></ProtectedRoute>} />

      {/* Beneficiary */}
      <Route path="/verification" element={<ProtectedRoute><Verification /></ProtectedRoute>} />

      {/* Admin */}
      <Route path="/admin" element={<ProtectedRoute roles={['admin']}><AdminOverview /></ProtectedRoute>} />
      <Route path="/admin/campaigns" element={<ProtectedRoute roles={['admin']}><AdminCampaigns /></ProtectedRoute>} />
      <Route path="/admin/donations" element={<ProtectedRoute roles={['admin']}><AdminDonations /></ProtectedRoute>} />
      <Route path="/admin/verification" element={<ProtectedRoute roles={['admin']}><VerificationQueue /></ProtectedRoute>} />
      <Route path="/admin/users" element={<ProtectedRoute roles={['admin']}><UserManagement /></ProtectedRoute>} />
      <Route path="/admin/reports" element={<ProtectedRoute roles={['admin']}><AdminReports /></ProtectedRoute>} />
      <Route path="/admin/fraud" element={<ProtectedRoute roles={['admin']}><FraudRisk /></ProtectedRoute>} />
      <Route path="/admin/support" element={<ProtectedRoute roles={['admin']}><SupportTickets /></ProtectedRoute>} />
      <Route path="/admin/audit-logs" element={<ProtectedRoute roles={['admin']}><AuditLogs /></ProtectedRoute>} />
    </Routes>
  );
}
