-- Interface connects the #invoke call from the template to the Layout submodules.
local interface = {};

-- Convert a template invocation into validated wikitext.
-- User input enters through frame.args; module policy enters through CFG.
-- The frame is gradually transformed into a call object that is safe for the
-- object-specific Layout renderer to consume.
function interface.main( frame, CFG, environment )  -- : string
	-- The call model stores all state that travels through the pipeline.
    local call = CFG.INCLUDE( environment, "call" ).init( CFG, environment );

	-- Pipeline modules: collect input, validate input, then render output.
	local luggage, security, flight = call.include( "luggage", "security", "flight" );

    -- Copy frame data and environment configuration into the call object.
    call = luggage.drop( call, frame, CFG, environment );
    
    -- Only the configured interface template may invoke this environment.
    call = security.authentication( call );
    
    -- Check whether the #invoke call used unknown internal parameter names.
    call = security.declaration( call );

    -- Translate valid named parameters from template language to internal values.
    if call.pass then call = luggage.carry_on( call ); end
    
    -- Scan the original template call on the page for unknown translated names.
    if call.pass then call = security.scan( call ); end
    
    -- Validate parameter values after names and translations are known.
    if call.pass then call = security.frisk( call ); end
    
    -- From here on, the call is expected to be structurally valid.
    
    -- Convert, complete and enrich the call before rendering.
    if call.pass then call = luggage.loading( call ); end

    -- Accumulate output fragments into a single response object.
    local response = call.include( "response" ).init();
    
    -- Render the requested object if validation still allows the call to pass.
 	if call.pass then response.add( flight.takeoff( call ) ); end
	
	-- Reserved hook for post-render checks.
	if call.pass then response.add( flight.landed( call ) ); end

	-- Keep only the fields needed for user-facing feedback.
	call = luggage.claim( call );
	
	-- Append mistakes, debug information or help depending on support settings.
	response.add( flight.feedback( call ) );
	
	-- The template receives plain wikitext.
    return mw.text.trim( tostring( response.get() ) );
end

return interface;
