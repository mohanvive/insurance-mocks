import ballerina/http;

listener http:Listener claimsListener = check new http:Listener(8081);

function init() {
    initSeedData();
}

service /claims/v1 on claimsListener {

    // ─── Claims ───────────────────────────────────────────────────────────────

    // List all claims with optional filters
    resource function get claims(@http:Query string? policyId, @http:Query string? claimType,
            @http:Query string? status, @http:Query int page = 1, @http:Query int pageSize = 10)
            returns ClaimListResponse {
        return getAllClaims(policyId, claimType, status, page, pageSize);
    }

    // Get a single claim by ID
    resource function get claims/[string claimId]()
            returns Claim|http:NotFound {
        Claim? clm = getClaimById(claimId);
        if clm is Claim {
            return clm;
        }
        http:NotFound notFound = {
            body: buildError("CLAIM_NOT_FOUND", string `Claim with ID '${claimId}' not found`)
        };
        return notFound;
    }

    // File a new claim
    resource function post claims(@http:Payload ClaimFileRequest payload)
            returns Claim|http:BadRequest|http:Created {
        if payload.lossDescription.trim().length() == 0 {
            http:BadRequest badReq = {
                body: buildError("INVALID_REQUEST", "Loss description is required")
            };
            return badReq;
        }
        Claim newClaim = fileClaim(payload);
        http:Created created = {body: newClaim};
        return created;
    }

    // Update claim details (status, amounts, adjuster assignment)
    resource function put claims/[string claimId](@http:Payload ClaimUpdateRequest payload)
            returns Claim|http:NotFound|http:BadRequest {
        Claim? updated = updateClaim(claimId, payload);
        if updated is Claim {
            return updated;
        }
        http:NotFound notFound = {
            body: buildError("CLAIM_NOT_FOUND", string `Claim with ID '${claimId}' not found`)
        };
        return notFound;
    }

    // Close a claim
    resource function post claims/[string claimId]/close(@http:Payload ClaimCloseRequest payload)
            returns Claim|http:NotFound|http:BadRequest {
        Claim? existing = getClaimById(claimId);
        if existing is () {
            http:NotFound notFound = {
                body: buildError("CLAIM_NOT_FOUND", string `Claim with ID '${claimId}' not found`)
            };
            return notFound;
        }
        string existingStatus = existing.claimStatus;
        if existingStatus == CLOSED {
            http:BadRequest badReq = {
                body: buildError("ALREADY_CLOSED", "Claim is already closed")
            };
            return badReq;
        }
        Claim? closed = closeClaim(claimId, payload);
        if closed is Claim {
            return closed;
        }
        http:NotFound notFound = {
            body: buildError("CLAIM_NOT_FOUND", string `Claim with ID '${claimId}' not found`)
        };
        return notFound;
    }

    // Reopen a closed or denied claim
    resource function post claims/[string claimId]/reopen()
            returns Claim|http:NotFound|http:BadRequest {
        Claim? existing = getClaimById(claimId);
        if existing is () {
            http:NotFound notFound = {
                body: buildError("CLAIM_NOT_FOUND", string `Claim with ID '${claimId}' not found`)
            };
            return notFound;
        }
        string existingStatus = existing.claimStatus;
        if existingStatus != CLOSED && existingStatus != DENIED {
            http:BadRequest badReq = {
                body: buildError("INVALID_STATE", "Only CLOSED or DENIED claims can be reopened")
            };
            return badReq;
        }
        Claim? reopened = reopenClaim(claimId);
        if reopened is Claim {
            return reopened;
        }
        http:NotFound notFound = {
            body: buildError("CLAIM_NOT_FOUND", string `Claim with ID '${claimId}' not found`)
        };
        return notFound;
    }

    // ─── Claim Notes ──────────────────────────────────────────────────────────

    // List notes for a claim
    resource function get claims/[string claimId]/notes()
            returns ClaimNote[]|http:NotFound {
        Claim? clm = getClaimById(claimId);
        if clm is Claim {
            return clm.notes;
        }
        http:NotFound notFound = {
            body: buildError("CLAIM_NOT_FOUND", string `Claim with ID '${claimId}' not found`)
        };
        return notFound;
    }

    // Add a note to a claim
    resource function post claims/[string claimId]/notes(@http:Payload ClaimNoteRequest payload)
            returns ClaimNote|http:NotFound|http:BadRequest|http:Created {
        if payload.noteText.trim().length() == 0 {
            http:BadRequest badReq = {
                body: buildError("INVALID_REQUEST", "Note text cannot be empty")
            };
            return badReq;
        }
        ClaimNote? newNote = addNote(claimId, payload);
        if newNote is ClaimNote {
            http:Created created = {body: newNote};
            return created;
        }
        http:NotFound notFound = {
            body: buildError("CLAIM_NOT_FOUND", string `Claim with ID '${claimId}' not found`)
        };
        return notFound;
    }

    // ─── Claim Documents ──────────────────────────────────────────────────────

    // List documents for a claim
    resource function get claims/[string claimId]/documents()
            returns ClaimDocument[]|http:NotFound {
        Claim? clm = getClaimById(claimId);
        if clm is Claim {
            return clm.documents;
        }
        http:NotFound notFound = {
            body: buildError("CLAIM_NOT_FOUND", string `Claim with ID '${claimId}' not found`)
        };
        return notFound;
    }

    // Add a document to a claim
    resource function post claims/[string claimId]/documents(@http:Payload ClaimDocumentRequest payload)
            returns ClaimDocument|http:NotFound|http:BadRequest|http:Created {
        if payload.fileName.trim().length() == 0 {
            http:BadRequest badReq = {
                body: buildError("INVALID_REQUEST", "File name cannot be empty")
            };
            return badReq;
        }
        ClaimDocument? newDoc = addDocument(claimId, payload);
        if newDoc is ClaimDocument {
            http:Created created = {body: newDoc};
            return created;
        }
        http:NotFound notFound = {
            body: buildError("CLAIM_NOT_FOUND", string `Claim with ID '${claimId}' not found`)
        };
        return notFound;
    }

    // Delete a document from a claim
    resource function delete claims/[string claimId]/documents/[string documentId]()
            returns SuccessResponse|http:NotFound {
        boolean removed = removeDocument(claimId, documentId);
        if removed {
            return buildSuccess(string `Document '${documentId}' removed from claim '${claimId}'`);
        }
        http:NotFound notFound = {
            body: buildError("NOT_FOUND", string `Claim '${claimId}' or document '${documentId}' not found`)
        };
        return notFound;
    }

    // ─── Claim Payments ───────────────────────────────────────────────────────

    // List payments for a claim
    resource function get claims/[string claimId]/payments()
            returns ClaimPayment[]|http:NotFound {
        Claim? clm = getClaimById(claimId);
        if clm is Claim {
            return clm.payments;
        }
        http:NotFound notFound = {
            body: buildError("CLAIM_NOT_FOUND", string `Claim with ID '${claimId}' not found`)
        };
        return notFound;
    }

    // Record a payment for a claim
    resource function post claims/[string claimId]/payments(@http:Payload ClaimPaymentRequest payload)
            returns ClaimPayment|http:NotFound|http:BadRequest|http:Created {
        if payload.paymentAmount <= 0.0d {
            http:BadRequest badReq = {
                body: buildError("INVALID_REQUEST", "Payment amount must be greater than zero")
            };
            return badReq;
        }
        ClaimPayment? newPayment = addPayment(claimId, payload);
        if newPayment is ClaimPayment {
            http:Created created = {body: newPayment};
            return created;
        }
        http:NotFound notFound = {
            body: buildError("CLAIM_NOT_FOUND", string `Claim with ID '${claimId}' not found`)
        };
        return notFound;
    }
}
