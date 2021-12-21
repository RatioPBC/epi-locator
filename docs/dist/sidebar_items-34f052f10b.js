sidebarNodes={"extras":[{"group":"","headers":[{"anchor":"copyright-and-license","id":"Copyright and license"}],"id":"epi-locator","title":"Epi Locator"},{"group":"","headers":[{"anchor":"overview","id":"Overview"}],"id":"overview","title":"Overview"},{"group":"","headers":[],"id":"license","title":"LICENSE"}],"modules":[{"group":"","id":"EpiLocator","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"signer/0","id":"signer/0"}]}],"sections":[],"title":"EpiLocator"},{"group":"","id":"EpiLocator.Accounts","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"delete_admin_session_token/1","id":"delete_admin_session_token/1"},{"anchor":"delete_user_session_token/1","id":"delete_user_session_token/1"},{"anchor":"generate_admin_session_token/1","id":"generate_admin_session_token/1"},{"anchor":"generate_user_session_token/1","id":"generate_user_session_token/1"},{"anchor":"get_admin!/1","id":"get_admin!/1"},{"anchor":"get_admin_by_email/1","id":"get_admin_by_email/1"},{"anchor":"get_admin_by_email_password_and_totp/3","id":"get_admin_by_email_password_and_totp/3"},{"anchor":"get_admin_by_session_token/1","id":"get_admin_by_session_token/1"},{"anchor":"get_user_id_by_session_token/1","id":"get_user_id_by_session_token/1"},{"anchor":"otp_uri/2","id":"otp_uri/2"},{"anchor":"register_admin/1","id":"register_admin/1"}]}],"sections":[],"title":"EpiLocator.Accounts"},{"group":"","id":"EpiLocator.Accounts.Admin","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"confirm_changeset/1","id":"confirm_changeset/1"},{"anchor":"registration_changeset/3","id":"registration_changeset/3"},{"anchor":"valid_password?/2","id":"valid_password?/2"},{"anchor":"valid_verification_code?/2","id":"valid_verification_code?/2"},{"anchor":"validate_current_password/2","id":"validate_current_password/2"}]}],"sections":[],"title":"EpiLocator.Accounts.Admin"},{"group":"","id":"EpiLocator.Accounts.AdminToken","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"admin_and_contexts_query/2","id":"admin_and_contexts_query/2"},{"anchor":"build_email_token/2","id":"build_email_token/2"},{"anchor":"build_session_token/1","id":"build_session_token/1"},{"anchor":"token_and_context_query/2","id":"token_and_context_query/2"},{"anchor":"verify_change_email_token_query/2","id":"verify_change_email_token_query/2"},{"anchor":"verify_email_token_query/2","id":"verify_email_token_query/2"},{"anchor":"verify_session_token_query/1","id":"verify_session_token_query/1"}]}],"sections":[],"title":"EpiLocator.Accounts.AdminToken"},{"group":"","id":"EpiLocator.Accounts.UserToken","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"build_session_token/1","id":"build_session_token/1"},{"anchor":"decode/1","id":"decode/1"},{"anchor":"encode/1","id":"encode/1"},{"anchor":"generate_session_token/0","id":"generate_session_token/0"},{"anchor":"hash_bytes/1","id":"hash_bytes/1"},{"anchor":"session_token_query/1","id":"session_token_query/1"},{"anchor":"user_id_query/1","id":"user_id_query/1"},{"anchor":"verify_session_token_query/1","id":"verify_session_token_query/1"}]}],"sections":[],"title":"EpiLocator.Accounts.UserToken"},{"group":"","id":"EpiLocator.HTTPoisonSSL","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"poison_http_options/3","id":"poison_http_options/3"}]}],"sections":[],"title":"EpiLocator.HTTPoisonSSL"},{"group":"","id":"EpiLocator.LookupApiBehaviour","nodeGroups":[{"key":"callbacks","name":"Callbacks","nodes":[{"anchor":"c:lookup_person/1","id":"lookup_person/1"}]}],"sections":[],"title":"EpiLocator.LookupApiBehaviour"},{"group":"","id":"EpiLocator.Monitoring.Cloudwatch","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"flag_name/0","id":"flag_name/0"},{"anchor":"to_metric_data/2","id":"to_metric_data/2"}]}],"sections":[],"title":"EpiLocator.Monitoring.Cloudwatch"},{"group":"","id":"EpiLocator.Monitoring.MetricsAPIBehaviour","nodeGroups":[{"key":"callbacks","name":"Callbacks","nodes":[{"anchor":"c:send/2","id":"send/2"}]}],"sections":[],"title":"EpiLocator.Monitoring.MetricsAPIBehaviour"},{"group":"","id":"EpiLocator.Monitoring.TelemetryToLoggerBridge","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"handle_event/4","id":"handle_event/4"},{"anchor":"setup/0","id":"setup/0"},{"anchor":"telemetry_handler_id/0","id":"telemetry_handler_id/0"}]}],"sections":[],"title":"EpiLocator.Monitoring.TelemetryToLoggerBridge"},{"group":"","id":"EpiLocator.Monitoring.TelemetryToMetricsBridge","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"handle_event/4","id":"handle_event/4"},{"anchor":"setup/0","id":"setup/0"},{"anchor":"telemetry_handler_id/0","id":"telemetry_handler_id/0"}]}],"sections":[],"title":"EpiLocator.Monitoring.TelemetryToMetricsBridge"},{"group":"","id":"EpiLocator.Monitoring.TelemetryToQueryLogBridge","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"handle_event/4","id":"handle_event/4"},{"anchor":"setup/0","id":"setup/0"},{"anchor":"telemetry_handler_id/0","id":"telemetry_handler_id/0"}]}],"sections":[],"title":"EpiLocator.Monitoring.TelemetryToQueryLogBridge"},{"group":"","id":"EpiLocator.QueryResultLog","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"headers/0","id":"headers/0"},{"anchor":"in_year_and_month/2","id":"in_year_and_month/2"},{"anchor":"summaries/2","id":"summaries/2"},{"anchor":"summaries_headers/0","id":"summaries_headers/0"}]}],"sections":[],"title":"EpiLocator.QueryResultLog"},{"group":"","id":"EpiLocator.RefinementLog","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"headers/0","id":"headers/0"},{"anchor":"in_year_and_month/2","id":"in_year_and_month/2"},{"anchor":"summaries/2","id":"summaries/2"},{"anchor":"summary_headers/0","id":"summary_headers/0"}]}],"sections":[],"title":"EpiLocator.RefinementLog"},{"group":"","id":"EpiLocator.Repo","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"aggregate/3","id":"aggregate/3"},{"anchor":"aggregate/4","id":"aggregate/4"},{"anchor":"all/2","id":"all/2"},{"anchor":"checked_out?/0","id":"checked_out?/0"},{"anchor":"checkout/2","id":"checkout/2"},{"anchor":"child_spec/1","id":"child_spec/1"},{"anchor":"config/0","id":"config/0"},{"anchor":"default_options/1","id":"default_options/1"},{"anchor":"delete/2","id":"delete/2"},{"anchor":"delete!/2","id":"delete!/2"},{"anchor":"delete_all/2","id":"delete_all/2"},{"anchor":"exists?/2","id":"exists?/2"},{"anchor":"explain/3","id":"explain/3"},{"anchor":"get/3","id":"get/3"},{"anchor":"get!/3","id":"get!/3"},{"anchor":"get_by/3","id":"get_by/3"},{"anchor":"get_by!/3","id":"get_by!/3"},{"anchor":"get_dynamic_repo/0","id":"get_dynamic_repo/0"},{"anchor":"in_transaction?/0","id":"in_transaction?/0"},{"anchor":"init/2","id":"init/2"},{"anchor":"insert/2","id":"insert/2"},{"anchor":"insert!/2","id":"insert!/2"},{"anchor":"insert_all/3","id":"insert_all/3"},{"anchor":"insert_or_update/2","id":"insert_or_update/2"},{"anchor":"insert_or_update!/2","id":"insert_or_update!/2"},{"anchor":"load/2","id":"load/2"},{"anchor":"one/2","id":"one/2"},{"anchor":"one!/2","id":"one!/2"},{"anchor":"preload/3","id":"preload/3"},{"anchor":"prepare_query/3","id":"prepare_query/3"},{"anchor":"put_dynamic_repo/1","id":"put_dynamic_repo/1"},{"anchor":"query/3","id":"query/3"},{"anchor":"query!/3","id":"query!/3"},{"anchor":"reload/2","id":"reload/2"},{"anchor":"reload!/2","id":"reload!/2"},{"anchor":"rollback/1","id":"rollback/1"},{"anchor":"start_link/1","id":"start_link/1"},{"anchor":"stop/1","id":"stop/1"},{"anchor":"stream/2","id":"stream/2"},{"anchor":"to_sql/2","id":"to_sql/2"},{"anchor":"transaction/2","id":"transaction/2"},{"anchor":"update/2","id":"update/2"},{"anchor":"update!/2","id":"update!/2"},{"anchor":"update_all/3","id":"update_all/3"}]}],"sections":[],"title":"EpiLocator.Repo"},{"group":"","id":"EpiLocator.Search.Cache","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"clear/1","id":"clear/1"},{"anchor":"exists?/2","id":"exists?/2"},{"anchor":"get/2","id":"get/2"},{"anchor":"put/3","id":"put/3"},{"anchor":"ttl/0","id":"ttl/0"}]}],"sections":[],"title":"EpiLocator.Search.Cache"},{"group":"","id":"EpiLocator.Search.CachingLookupApi","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"cache_key/3","id":"cache_key/3"},{"anchor":"exists?/1","id":"exists?/1"},{"anchor":"lookup_person/3","id":"lookup_person/3"}]}],"sections":[],"title":"EpiLocator.Search.CachingLookupApi"},{"group":"","id":"EpiLocator.Search.FilterPersonResults","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"filter/2","id":"filter/2"}]}],"sections":[],"title":"EpiLocator.Search.FilterPersonResults"},{"group":"","id":"EpiLocator.Search.PersonResult","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"namespace/0","id":"namespace/0"},{"anchor":"new/1","id":"new/1"},{"anchor":"person_dominant_values/1","id":"person_dominant_values/1"},{"anchor":"person_dominant_values_key/0","id":"person_dominant_values_key/0"},{"anchor":"unavailable_dob_string/0","id":"unavailable_dob_string/0"}]}],"sections":[],"title":"EpiLocator.Search.PersonResult"},{"group":"","id":"EpiLocator.Search.PersonSearchResults","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"new/1","id":"new/1"}]}],"sections":[],"title":"EpiLocator.Search.PersonSearchResults"},{"group":"","id":"EpiLocator.SearchChooser","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"changeset/2","id":"changeset/2"}]}],"sections":[],"title":"EpiLocator.SearchChooser"},{"group":"","id":"EpiLocator.Signature","nodeGroups":[{"key":"callbacks","name":"Callbacks","nodes":[{"anchor":"c:valid?/3","id":"valid?/3"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"digest/3","id":"digest/3"},{"anchor":"encode/1","id":"encode/1"},{"anchor":"encode16/1","id":"encode16/1"},{"anchor":"expired?/3","id":"expired?/3"},{"anchor":"get_conn_info/1","id":"get_conn_info/1"},{"anchor":"get_message/2","id":"get_message/2"},{"anchor":"hash/1","id":"hash/1"},{"anchor":"nonce/1","id":"nonce/1"},{"anchor":"sign/2","id":"sign/2"},{"anchor":"ttl/1","id":"ttl/1"},{"anchor":"valid?/3","id":"valid?/3"},{"anchor":"valid_signature?/3","id":"valid_signature?/3"}]}],"sections":[],"title":"EpiLocator.Signature"},{"group":"","id":"EpiLocator.Signature.Cache","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"clear/1","id":"clear/1"},{"anchor":"exists?/2","id":"exists?/2"},{"anchor":"get/2","id":"get/2"},{"anchor":"put/3","id":"put/3"}]}],"sections":[],"title":"EpiLocator.Signature.Cache"},{"group":"","id":"EpiLocator.System.Behaviour","nodeGroups":[{"key":"callbacks","name":"Callbacks","nodes":[{"anchor":"c:monotonic_time/1","id":"monotonic_time/1"}]}],"sections":[],"title":"EpiLocator.System.Behaviour"},{"group":"","id":"EpiLocator.System.Real","sections":[],"title":"EpiLocator.System.Real"},{"group":"","id":"EpiLocator.TRClient","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"cert_password/0","id":"cert_password/0"},{"anchor":"flag_name/0","id":"flag_name/0"},{"anchor":"format_date/1","id":"format_date/1"},{"anchor":"http_options/0","id":"http_options/0"},{"anchor":"person_search_body/1","id":"person_search_body/1"},{"anchor":"person_search_url/0","id":"person_search_url/0"},{"anchor":"private_key/0","id":"private_key/0"},{"anchor":"public_cert/0","id":"public_cert/0"},{"anchor":"url/1","id":"url/1"}]}],"sections":[],"title":"EpiLocator.TRClient"},{"group":"","id":"EpiLocator.TRClientBehaviour","nodeGroups":[{"key":"callbacks","name":"Callbacks","nodes":[{"anchor":"c:person_search/1","id":"person_search/1"},{"anchor":"c:person_search_results/1","id":"person_search_results/1"}]}],"sections":[],"title":"EpiLocator.TRClientBehaviour"},{"group":"","id":"EpiLocator.ThomsonReuters.Config","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"init/0","id":"init/0"}]}],"sections":[],"title":"EpiLocator.ThomsonReuters.Config"},{"group":"","id":"EpiLocator.Time.Behaviour","nodeGroups":[{"key":"callbacks","name":"Callbacks","nodes":[{"anchor":"c:utc_now/0","id":"utc_now/0"}]}],"sections":[],"title":"EpiLocator.Time.Behaviour"},{"group":"","id":"EpiLocator.Time.Real","sections":[],"title":"EpiLocator.Time.Real"},{"group":"","id":"EpiLocator.TrApi","sections":[],"title":"EpiLocator.TrApi"},{"group":"","id":"EpiLocatorWeb","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"__using__/1","id":"__using__/1"},{"anchor":"channel/0","id":"channel/0"},{"anchor":"controller/0","id":"controller/0"},{"anchor":"live_component/0","id":"live_component/0"},{"anchor":"live_view/0","id":"live_view/0"},{"anchor":"router/0","id":"router/0"},{"anchor":"view/0","id":"view/0"}]}],"sections":[],"title":"EpiLocatorWeb"},{"group":"","id":"EpiLocatorWeb.AdminAuth","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"fetch_current_admin/2","id":"fetch_current_admin/2"},{"anchor":"log_in_admin/3","id":"log_in_admin/3"},{"anchor":"log_out_admin/1","id":"log_out_admin/1"},{"anchor":"redirect_if_admin_is_authenticated/2","id":"redirect_if_admin_is_authenticated/2"},{"anchor":"require_authenticated_admin/2","id":"require_authenticated_admin/2"}]}],"sections":[],"title":"EpiLocatorWeb.AdminAuth"},{"group":"","id":"EpiLocatorWeb.AdminSessionController","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"create/2","id":"create/2"},{"anchor":"delete/2","id":"delete/2"},{"anchor":"new/2","id":"new/2"}]}],"sections":[],"title":"EpiLocatorWeb.AdminSessionController"},{"group":"","id":"EpiLocatorWeb.AdminSessionView","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"__resource__/0","id":"__resource__/0"},{"anchor":"app_name/0","id":"app_name/0"},{"anchor":"noreply/1","id":"noreply/1"},{"anchor":"ok/1","id":"ok/1"},{"anchor":"render/2","id":"render/2"},{"anchor":"template_not_found/2","id":"template_not_found/2"}]}],"sections":[],"title":"EpiLocatorWeb.AdminSessionView"},{"group":"","id":"EpiLocatorWeb.Endpoint","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"broadcast/3","id":"broadcast/3"},{"anchor":"broadcast!/3","id":"broadcast!/3"},{"anchor":"broadcast_from/4","id":"broadcast_from/4"},{"anchor":"broadcast_from!/4","id":"broadcast_from!/4"},{"anchor":"call/2","id":"call/2"},{"anchor":"child_spec/1","id":"child_spec/1"},{"anchor":"config/2","id":"config/2"},{"anchor":"config_change/2","id":"config_change/2"},{"anchor":"host/0","id":"host/0"},{"anchor":"init/1","id":"init/1"},{"anchor":"local_broadcast/3","id":"local_broadcast/3"},{"anchor":"local_broadcast_from/4","id":"local_broadcast_from/4"},{"anchor":"path/1","id":"path/1"},{"anchor":"script_name/0","id":"script_name/0"},{"anchor":"start_link/1","id":"start_link/1"},{"anchor":"static_integrity/1","id":"static_integrity/1"},{"anchor":"static_lookup/1","id":"static_lookup/1"},{"anchor":"static_path/1","id":"static_path/1"},{"anchor":"static_url/0","id":"static_url/0"},{"anchor":"struct_url/0","id":"struct_url/0"},{"anchor":"subscribe/2","id":"subscribe/2"},{"anchor":"unsubscribe/1","id":"unsubscribe/1"},{"anchor":"url/0","id":"url/0"}]}],"sections":[],"title":"EpiLocatorWeb.Endpoint"},{"group":"","id":"EpiLocatorWeb.ErrorHelpers","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"error_tag/2","id":"error_tag/2"},{"anchor":"translate_error/1","id":"translate_error/1"}]}],"sections":[],"title":"EpiLocatorWeb.ErrorHelpers"},{"group":"","id":"EpiLocatorWeb.ErrorView","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"__resource__/0","id":"__resource__/0"},{"anchor":"app_name/0","id":"app_name/0"},{"anchor":"noreply/1","id":"noreply/1"},{"anchor":"ok/1","id":"ok/1"},{"anchor":"render/2","id":"render/2"},{"anchor":"template_not_found/2","id":"template_not_found/2"}]}],"sections":[],"title":"EpiLocatorWeb.ErrorView"},{"group":"","id":"EpiLocatorWeb.Gettext","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"dgettext/3","id":"dgettext/3"},{"anchor":"dgettext_noop/2","id":"dgettext_noop/2"},{"anchor":"dngettext/5","id":"dngettext/5"},{"anchor":"dngettext_noop/3","id":"dngettext_noop/3"},{"anchor":"dpgettext/4","id":"dpgettext/4"},{"anchor":"dpgettext_noop/3","id":"dpgettext_noop/3"},{"anchor":"dpngettext/6","id":"dpngettext/6"},{"anchor":"dpngettext_noop/4","id":"dpngettext_noop/4"},{"anchor":"gettext/2","id":"gettext/2"},{"anchor":"gettext_comment/1","id":"gettext_comment/1"},{"anchor":"gettext_noop/1","id":"gettext_noop/1"},{"anchor":"handle_missing_bindings/2","id":"handle_missing_bindings/2"},{"anchor":"handle_missing_plural_translation/6","id":"handle_missing_plural_translation/6"},{"anchor":"handle_missing_translation/4","id":"handle_missing_translation/4"},{"anchor":"lgettext/5","id":"lgettext/5"},{"anchor":"lngettext/7","id":"lngettext/7"},{"anchor":"ngettext/4","id":"ngettext/4"},{"anchor":"ngettext_noop/2","id":"ngettext_noop/2"},{"anchor":"pgettext/3","id":"pgettext/3"},{"anchor":"pgettext_noop/2","id":"pgettext_noop/2"},{"anchor":"pngettext/5","id":"pngettext/5"},{"anchor":"pngettext_noop/3","id":"pngettext_noop/3"}]}],"sections":[],"title":"EpiLocatorWeb.Gettext"},{"group":"","id":"EpiLocatorWeb.HealthCheckController","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"index/2","id":"index/2"}]}],"sections":[],"title":"EpiLocatorWeb.HealthCheckController"},{"group":"","id":"EpiLocatorWeb.LayoutView","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"__resource__/0","id":"__resource__/0"},{"anchor":"app_name/0","id":"app_name/0"},{"anchor":"favicon_href/1","id":"favicon_href/1"},{"anchor":"header_logo_link/1","id":"header_logo_link/1"},{"anchor":"noreply/1","id":"noreply/1"},{"anchor":"ok/1","id":"ok/1"},{"anchor":"render/2","id":"render/2"},{"anchor":"template_not_found/2","id":"template_not_found/2"},{"anchor":"title_tag/1","id":"title_tag/1"}]}],"sections":[],"title":"EpiLocatorWeb.LayoutView"},{"group":"","id":"EpiLocatorWeb.LiveComponents.RefineSearchResults","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"app_name/0","id":"app_name/0"},{"anchor":"days/0","id":"days/0"},{"anchor":"handle_event/3","id":"handle_event/3"},{"anchor":"months/0","id":"months/0"},{"anchor":"noreply/1","id":"noreply/1"},{"anchor":"ok/1","id":"ok/1"},{"anchor":"preload/1","id":"preload/1"},{"anchor":"render/1","id":"render/1"},{"anchor":"states/0","id":"states/0"},{"anchor":"years/0","id":"years/0"}]}],"sections":[],"title":"EpiLocatorWeb.LiveComponents.RefineSearchResults"},{"group":"","id":"EpiLocatorWeb.LiveComponents.RefineSearchResults.FiltersForm","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"changeset/2","id":"changeset/2"},{"anchor":"filters_form/1","id":"filters_form/1"}]}],"sections":[],"title":"EpiLocatorWeb.LiveComponents.RefineSearchResults.FiltersForm"},{"group":"","id":"EpiLocatorWeb.MetricsController","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"all/2","id":"all/2"},{"anchor":"index/2","id":"index/2"},{"anchor":"refinement_all/2","id":"refinement_all/2"},{"anchor":"refinement_summaries/2","id":"refinement_summaries/2"},{"anchor":"send_csv/3","id":"send_csv/3"},{"anchor":"summaries/2","id":"summaries/2"}]}],"sections":[],"title":"EpiLocatorWeb.MetricsController"},{"group":"","id":"EpiLocatorWeb.MetricsView","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"__resource__/0","id":"__resource__/0"},{"anchor":"app_name/0","id":"app_name/0"},{"anchor":"months_since_launch/0","id":"months_since_launch/0"},{"anchor":"noreply/1","id":"noreply/1"},{"anchor":"ok/1","id":"ok/1"},{"anchor":"render/2","id":"render/2"},{"anchor":"template_not_found/2","id":"template_not_found/2"}]}],"sections":[],"title":"EpiLocatorWeb.MetricsView"},{"group":"","id":"EpiLocatorWeb.PageController","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"commcare_signature/2","id":"commcare_signature/2"},{"anchor":"index/2","id":"index/2"}]}],"sections":[],"title":"EpiLocatorWeb.PageController"},{"group":"","id":"EpiLocatorWeb.PageView","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"__resource__/0","id":"__resource__/0"},{"anchor":"app_name/0","id":"app_name/0"},{"anchor":"noreply/1","id":"noreply/1"},{"anchor":"ok/1","id":"ok/1"},{"anchor":"render/2","id":"render/2"},{"anchor":"template_not_found/2","id":"template_not_found/2"}]}],"sections":[],"title":"EpiLocatorWeb.PageView"},{"group":"","id":"EpiLocatorWeb.Plugs.PutRequestIdOnSession","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"call/2","id":"call/2"},{"anchor":"init/1","id":"init/1"}]}],"sections":[],"title":"EpiLocatorWeb.Plugs.PutRequestIdOnSession"},{"group":"","id":"EpiLocatorWeb.Plugs.RequireValidSignature","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"call/2","id":"call/2"},{"anchor":"commcare_signature_key/0","id":"commcare_signature_key/0"},{"anchor":"commcare_signature_secret/0","id":"commcare_signature_secret/0"},{"anchor":"get_path/1","id":"get_path/1"},{"anchor":"get_query_string/1","id":"get_query_string/1"},{"anchor":"get_signature/1","id":"get_signature/1"},{"anchor":"get_user_id/1","id":"get_user_id/1"},{"anchor":"init/1","id":"init/1"}]}],"sections":[],"title":"EpiLocatorWeb.Plugs.RequireValidSignature"},{"group":"","id":"EpiLocatorWeb.Router","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"api/2","id":"api/2"},{"anchor":"browser/2","id":"browser/2"},{"anchor":"call/2","id":"call/2"},{"anchor":"init/1","id":"init/1"},{"anchor":"private_web/2","id":"private_web/2"},{"anchor":"put_request_id_on_session/2","id":"put_request_id_on_session/2"},{"anchor":"require_valid_signature/2","id":"require_valid_signature/2"}]}],"sections":[],"title":"EpiLocatorWeb.Router"},{"group":"","id":"EpiLocatorWeb.Router.Helpers","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"admin_session_path/2","id":"admin_session_path/2"},{"anchor":"admin_session_path/3","id":"admin_session_path/3"},{"anchor":"admin_session_url/2","id":"admin_session_url/2"},{"anchor":"admin_session_url/3","id":"admin_session_url/3"},{"anchor":"health_check_path/2","id":"health_check_path/2"},{"anchor":"health_check_path/3","id":"health_check_path/3"},{"anchor":"health_check_url/2","id":"health_check_url/2"},{"anchor":"health_check_url/3","id":"health_check_url/3"},{"anchor":"live_dashboard_path/2","id":"live_dashboard_path/2"},{"anchor":"live_dashboard_path/3","id":"live_dashboard_path/3"},{"anchor":"live_dashboard_path/4","id":"live_dashboard_path/4"},{"anchor":"live_dashboard_path/5","id":"live_dashboard_path/5"},{"anchor":"live_dashboard_url/2","id":"live_dashboard_url/2"},{"anchor":"live_dashboard_url/3","id":"live_dashboard_url/3"},{"anchor":"live_dashboard_url/4","id":"live_dashboard_url/4"},{"anchor":"live_dashboard_url/5","id":"live_dashboard_url/5"},{"anchor":"metrics_path/2","id":"metrics_path/2"},{"anchor":"metrics_path/3","id":"metrics_path/3"},{"anchor":"metrics_path/4","id":"metrics_path/4"},{"anchor":"metrics_path/5","id":"metrics_path/5"},{"anchor":"metrics_url/2","id":"metrics_url/2"},{"anchor":"metrics_url/3","id":"metrics_url/3"},{"anchor":"metrics_url/4","id":"metrics_url/4"},{"anchor":"metrics_url/5","id":"metrics_url/5"},{"anchor":"page_path/2","id":"page_path/2"},{"anchor":"page_path/3","id":"page_path/3"},{"anchor":"page_url/2","id":"page_url/2"},{"anchor":"page_url/3","id":"page_url/3"},{"anchor":"path/2","id":"path/2"},{"anchor":"search_path/2","id":"search_path/2"},{"anchor":"search_path/3","id":"search_path/3"},{"anchor":"search_url/2","id":"search_url/2"},{"anchor":"search_url/3","id":"search_url/3"},{"anchor":"signature_path/2","id":"signature_path/2"},{"anchor":"signature_path/3","id":"signature_path/3"},{"anchor":"signature_url/2","id":"signature_url/2"},{"anchor":"signature_url/3","id":"signature_url/3"},{"anchor":"static_integrity/2","id":"static_integrity/2"},{"anchor":"static_path/2","id":"static_path/2"},{"anchor":"static_url/2","id":"static_url/2"},{"anchor":"url/1","id":"url/1"}]}],"sections":[],"title":"EpiLocatorWeb.Router.Helpers"},{"group":"","id":"EpiLocatorWeb.SearchLive","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"app_name/0","id":"app_name/0"},{"anchor":"handle_event/3","id":"handle_event/3"},{"anchor":"handle_info/2","id":"handle_info/2"},{"anchor":"mount/3","id":"mount/3"},{"anchor":"noreply/1","id":"noreply/1"},{"anchor":"ok/1","id":"ok/1"},{"anchor":"refine_results_flag_name/0","id":"refine_results_flag_name/0"},{"anchor":"refine_search_results/1","id":"refine_search_results/1"},{"anchor":"render/1","id":"render/1"},{"anchor":"reset_refine_form/1","id":"reset_refine_form/1"}]}],"sections":[],"title":"EpiLocatorWeb.SearchLive"},{"group":"","id":"EpiLocatorWeb.SearchView","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:search_type/0","id":"search_type/0"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"__resource__/0","id":"__resource__/0"},{"anchor":"app_name/0","id":"app_name/0"},{"anchor":"chosen_name/2","id":"chosen_name/2"},{"anchor":"format_date/1","id":"format_date/1"},{"anchor":"full_name/1","id":"full_name/1"},{"anchor":"noreply/1","id":"noreply/1"},{"anchor":"number_of_search_results/1","id":"number_of_search_results/1"},{"anchor":"ok/1","id":"ok/1"},{"anchor":"parent_guardian_present?/1","id":"parent_guardian_present?/1"},{"anchor":"raw_phone_number/1","id":"raw_phone_number/1"},{"anchor":"render/2","id":"render/2"},{"anchor":"search_criteria/7","id":"search_criteria/7"},{"anchor":"show_if_present/1","id":"show_if_present/1"},{"anchor":"show_refine_search_results?/2","id":"show_refine_search_results?/2"},{"anchor":"template_not_found/2","id":"template_not_found/2"}]}],"sections":[],"title":"EpiLocatorWeb.SearchView"},{"group":"","id":"EpiLocatorWeb.SignatureController","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"verify/2","id":"verify/2"}]}],"sections":[],"title":"EpiLocatorWeb.SignatureController"},{"group":"","id":"EpiLocatorWeb.TRView","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"__resource__/0","id":"__resource__/0"},{"anchor":"app_name/0","id":"app_name/0"},{"anchor":"noreply/1","id":"noreply/1"},{"anchor":"ok/1","id":"ok/1"},{"anchor":"render/2","id":"render/2"},{"anchor":"template_not_found/2","id":"template_not_found/2"}]}],"sections":[],"title":"EpiLocatorWeb.TRView"},{"group":"","id":"EpiLocatorWeb.Telemetry","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"child_spec/1","id":"child_spec/1"},{"anchor":"metrics/0","id":"metrics/0"},{"anchor":"start_link/1","id":"start_link/1"}]}],"sections":[],"title":"EpiLocatorWeb.Telemetry"},{"group":"","id":"EpiLocatorWeb.UserSocket","sections":[],"title":"EpiLocatorWeb.UserSocket"}],"tasks":[]}