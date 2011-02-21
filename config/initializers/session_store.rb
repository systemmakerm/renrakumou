# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_renrakumou.app_session',
  :secret      => '724c2180e5969f9ec41f6ae0b3f2971a27a3dc253b916ebec0852106a1f841580988f9b52d934ff5737eb208bf7e67a0bcac7bd8fff7e43c60fdbe52f3d79bc7',
  :cookie_only => false
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
ActionController::Base.session_store = :active_record_store
