import ballerina/http;

listener http:Listener insuranceListener = check new http:Listener(8080);

function init() {
    initSeedData();
}

service /insurance/v1 on insuranceListener {

    // ─── Policies ────────────────────────────────────────────────────────────

    // List all policies with optional filters
    resource function get policies(@http:Query string? policyType, @http:Query string? status,
            @http:Query int page = 1, @http:Query int pageSize = 10)
            returns PolicyListResponse|ErrorResponse {
        return getAllPolicies(policyType, status, page, pageSize);
    }

    // Get a single policy by ID
    resource function get policies/[string policyId]()
            returns Policy|http:NotFound {
        Policy? pol = getPolicyById(policyId);
        if pol is Policy {
            return pol;
        }
        http:NotFound notFound = {
            body: buildError("POLICY_NOT_FOUND", string `Policy with ID '${policyId}' not found`)
        };
        return notFound;
    }

    // Create a new policy
    resource function post policies(@http:Payload PolicyCreateRequest payload)
            returns Policy|http:BadRequest|http:Created {
        if payload.coverages.length() == 0 {
            http:BadRequest badReq = {
                body: buildError("INVALID_REQUEST", "At least one coverage is required")
            };
            return badReq;
        }
        Policy newPolicy = createPolicy(payload);
        http:Created created = {body: newPolicy};
        return created;
    }

    // Update an existing policy
    resource function put policies/[string policyId](@http:Payload PolicyUpdateRequest payload)
            returns Policy|http:NotFound|http:BadRequest {
        Policy? updated = updatePolicy(policyId, payload);
        if updated is Policy {
            return updated;
        }
        http:NotFound notFound = {
            body: buildError("POLICY_NOT_FOUND", string `Policy with ID '${policyId}' not found`)
        };
        return notFound;
    }

    // Cancel a policy
    resource function post policies/[string policyId]/cancel(@http:Payload PolicyCancelRequest payload)
            returns Policy|http:NotFound|http:BadRequest {
        Policy? existing = getPolicyById(policyId);
        if existing is () {
            http:NotFound notFound = {
                body: buildError("POLICY_NOT_FOUND", string `Policy with ID '${policyId}' not found`)
            };
            return notFound;
        }
        string existingStatus = existing.policyStatus;
        if existingStatus == CANCELLED {
            http:BadRequest badReq = {
                body: buildError("ALREADY_CANCELLED", "Policy is already cancelled")
            };
            return badReq;
        }
        Policy? cancelled = cancelPolicy(policyId, payload);
        if cancelled is Policy {
            return cancelled;
        }
        http:NotFound notFound = {
            body: buildError("POLICY_NOT_FOUND", string `Policy with ID '${policyId}' not found`)
        };
        return notFound;
    }

    // Delete a policy
    resource function delete policies/[string policyId]()
            returns SuccessResponse|http:NotFound {
        boolean deleted = deletePolicy(policyId);
        if deleted {
            return buildSuccess(string `Policy '${policyId}' has been deleted`);
        }
        http:NotFound notFound = {
            body: buildError("POLICY_NOT_FOUND", string `Policy with ID '${policyId}' not found`)
        };
        return notFound;
    }

    // ─── Quotes ──────────────────────────────────────────────────────────────

    // List all quotes with optional filters
    resource function get quotes(@http:Query string? policyType, @http:Query string? status,
            @http:Query int page = 1, @http:Query int pageSize = 10)
            returns QuoteListResponse|ErrorResponse {
        return getAllQuotes(policyType, status, page, pageSize);
    }

    // Get a single quote by ID
    resource function get quotes/[string quoteId]()
            returns Quote|http:NotFound {
        Quote? qte = getQuoteById(quoteId);
        if qte is Quote {
            return qte;
        }
        http:NotFound notFound = {
            body: buildError("QUOTE_NOT_FOUND", string `Quote with ID '${quoteId}' not found`)
        };
        return notFound;
    }

    // Request a new quote
    resource function post quotes(@http:Payload QuoteRequest payload)
            returns Quote|http:BadRequest|http:Created {
        if payload.desiredCoverages.length() == 0 {
            http:BadRequest badReq = {
                body: buildError("INVALID_REQUEST", "At least one coverage is required")
            };
            return badReq;
        }
        Quote newQuote = createQuote(payload);
        http:Created created = {body: newQuote};
        return created;
    }

    // Bind a quote to create a policy
    resource function post quotes/[string quoteId]/bind(@http:Payload QuoteBindRequest payload)
            returns Policy|http:NotFound|http:BadRequest {
        Quote? existing = getQuoteById(quoteId);
        if existing is () {
            http:NotFound notFound = {
                body: buildError("QUOTE_NOT_FOUND", string `Quote with ID '${quoteId}' not found`)
            };
            return notFound;
        }
        string existingStatus = existing.quoteStatus;
        if existingStatus == BOUND {
            http:BadRequest badReq = {
                body: buildError("ALREADY_BOUND", "Quote is already bound to a policy")
            };
            return badReq;
        }
        if existingStatus == EXPIRED {
            http:BadRequest badReq = {
                body: buildError("QUOTE_EXPIRED", "Cannot bind an expired quote")
            };
            return badReq;
        }
        Policy? newPolicy = bindQuoteToPolicy(quoteId, payload);
        if newPolicy is Policy {
            return newPolicy;
        }
        http:BadRequest badReq = {
            body: buildError("BIND_FAILED", "Failed to bind quote to policy")
        };
        return badReq;
    }

    // Expire a quote manually
    resource function post quotes/[string quoteId]/expire()
            returns Quote|http:NotFound {
        Quote? expired = expireQuote(quoteId);
        if expired is Quote {
            return expired;
        }
        http:NotFound notFound = {
            body: buildError("QUOTE_NOT_FOUND", string `Quote with ID '${quoteId}' not found`)
        };
        return notFound;
    }
}
