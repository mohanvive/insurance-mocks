// ─── Policy helper functions ──────────────────────────────────────────────────

isolated function getAllPolicies(string? policyType, string? status, int page, int pageSize)
        returns PolicyListResponse {
    Policy[] filtered;
    lock {
        Policy[] temp = [];
        foreach Policy pol in policyStore {
            boolean typeMatch = policyType is () || pol.policyType == policyType;
            boolean statusMatch = status is () || pol.policyStatus == status;
            if typeMatch && statusMatch {
                temp.push(pol.clone());
            }
        }
        filtered = temp.clone();
    }
    int total = filtered.length();
    int startIdx = (page - 1) * pageSize;
    int endIdx = startIdx + pageSize;
    if endIdx > total {
        endIdx = total;
    }
    Policy[] pageSlice = startIdx >= total ? [] : filtered.slice(startIdx, endIdx);
    return {total: total, page: page, pageSize: pageSize, policies: pageSlice};
}

isolated function getPolicyById(string policyId) returns Policy? {
    lock {
        Policy? pol = policyStore[policyId];
        if pol is Policy {
            return pol.clone();
        }
    }
    return ();
}

isolated function createPolicy(PolicyCreateRequest req) returns Policy {
    string newId = generateId();
    string now = currentTimestamp();
    decimal annualPremium = calculatePremium(req.coverages);
    Policy newPolicy = {
        policyId: newId,
        policyNumber: generatePolicyNumber(),
        policyType: req.policyType,
        policyStatus: PENDING,
        policyHolder: req.policyHolder,
        effectiveDate: req.effectiveDate,
        expirationDate: req.expirationDate,
        annualPremium: annualPremium,
        coverages: req.coverages,
        insuredVehicle: req.insuredVehicle,
        insuredProperty: req.insuredProperty,
        createdAt: now,
        updatedAt: now
    };
    Policy clonedPolicy = newPolicy.clone();
    lock {
        policyStore[newId] = clonedPolicy.clone();
    }
    return newPolicy;
}

isolated function updatePolicy(string policyId, PolicyUpdateRequest req) returns Policy? {
    Policy? existing = getPolicyById(policyId);
    if existing is () {
        return ();
    }
    string? newEffectiveDate = req.effectiveDate;
    string? newExpirationDate = req.expirationDate;
    Coverage[]? newCoverages = req.coverages;
    InsuredVehicle? newVehicle = req.insuredVehicle;
    InsuredProperty? newProperty = req.insuredProperty;

    Policy updated = {
        policyId: existing.policyId,
        policyNumber: existing.policyNumber,
        policyType: existing.policyType,
        policyStatus: existing.policyStatus,
        policyHolder: existing.policyHolder,
        effectiveDate: newEffectiveDate is string ? newEffectiveDate : existing.effectiveDate,
        expirationDate: newExpirationDate is string ? newExpirationDate : existing.expirationDate,
        annualPremium: newCoverages is Coverage[] ? calculatePremium(newCoverages) : existing.annualPremium,
        coverages: newCoverages is Coverage[] ? newCoverages : existing.coverages,
        insuredVehicle: newVehicle is InsuredVehicle ? newVehicle : existing.insuredVehicle,
        insuredProperty: newProperty is InsuredProperty ? newProperty : existing.insuredProperty,
        createdAt: existing.createdAt,
        updatedAt: currentTimestamp()
    };
    Policy clonedUpdated = updated.clone();
    lock {
        policyStore[policyId] = clonedUpdated.clone();
    }
    return updated;
}

isolated function cancelPolicy(string policyId, PolicyCancelRequest req) returns Policy? {
    Policy? existing = getPolicyById(policyId);
    if existing is () {
        return ();
    }
    Policy cancelled = {
        policyId: existing.policyId,
        policyNumber: existing.policyNumber,
        policyType: existing.policyType,
        policyStatus: CANCELLED,
        policyHolder: existing.policyHolder,
        effectiveDate: existing.effectiveDate,
        expirationDate: req.cancellationDate,
        annualPremium: existing.annualPremium,
        coverages: existing.coverages,
        insuredVehicle: existing.insuredVehicle,
        insuredProperty: existing.insuredProperty,
        createdAt: existing.createdAt,
        updatedAt: currentTimestamp()
    };
    Policy clonedCancelled = cancelled.clone();
    lock {
        policyStore[policyId] = clonedCancelled.clone();
    }
    return cancelled;
}

isolated function deletePolicy(string policyId) returns boolean {
    lock {
        if policyStore.hasKey(policyId) {
            _ = policyStore.remove(policyId);
            return true;
        }
    }
    return false;
}

// ─── Quote helper functions ───────────────────────────────────────────────────

isolated function getAllQuotes(string? policyType, string? status, int page, int pageSize)
        returns QuoteListResponse {
    Quote[] filtered;
    lock {
        Quote[] temp = [];
        foreach Quote qte in quoteStore {
            boolean typeMatch = policyType is () || qte.policyType == policyType;
            boolean statusMatch = status is () || qte.quoteStatus == status;
            if typeMatch && statusMatch {
                temp.push(qte.clone());
            }
        }
        filtered = temp.clone();
    }
    int total = filtered.length();
    int startIdx = (page - 1) * pageSize;
    int endIdx = startIdx + pageSize;
    if endIdx > total {
        endIdx = total;
    }
    Quote[] pageSlice = startIdx >= total ? [] : filtered.slice(startIdx, endIdx);
    return {total: total, page: page, pageSize: pageSize, quotes: pageSlice};
}

isolated function getQuoteById(string quoteId) returns Quote? {
    lock {
        Quote? qte = quoteStore[quoteId];
        if qte is Quote {
            return qte.clone();
        }
    }
    return ();
}

isolated function createQuote(QuoteRequest req) returns Quote {
    string newId = generateId();
    string now = currentTimestamp();
    decimal annualPremium = calculatePremium(req.desiredCoverages);
    decimal monthlyPremium = annualPremium / 12.0d;
    Quote newQuote = {
        quoteId: newId,
        quoteNumber: generateQuoteNumber(),
        policyType: req.policyType,
        quoteStatus: ISSUED,
        applicant: req.applicant,
        riskDetails: req.riskDetails,
        proposedCoverages: req.desiredCoverages,
        estimatedAnnualPremium: annualPremium,
        estimatedMonthlyPremium: monthlyPremium,
        quoteValidUntil: "2026-12-31",
        boundPolicyId: (),
        createdAt: now,
        updatedAt: now
    };
    Quote clonedQuote = newQuote.clone();
    lock {
        quoteStore[newId] = clonedQuote.clone();
    }
    return newQuote;
}

isolated function bindQuoteToPolicy(string quoteId, QuoteBindRequest req) returns Policy? {
    Quote? existing = getQuoteById(quoteId);
    if existing is () {
        return ();
    }
    string existingStatus = existing.quoteStatus;
    if existingStatus == BOUND || existingStatus == EXPIRED {
        return ();
    }
    string newPolicyId = generateId();
    string now = currentTimestamp();
    Policy newPolicy = {
        policyId: newPolicyId,
        policyNumber: generatePolicyNumber(),
        policyType: existing.policyType,
        policyStatus: ACTIVE,
        policyHolder: existing.applicant,
        effectiveDate: req.effectiveDate,
        expirationDate: "2027-01-01",
        annualPremium: existing.estimatedAnnualPremium,
        coverages: existing.proposedCoverages,
        insuredVehicle: existing.riskDetails.vehicle,
        insuredProperty: existing.riskDetails.property,
        createdAt: now,
        updatedAt: now
    };
    Policy clonedPolicy = newPolicy.clone();
    lock {
        policyStore[newPolicyId] = clonedPolicy.clone();
    }

    Quote boundQuote = {
        quoteId: existing.quoteId,
        quoteNumber: existing.quoteNumber,
        policyType: existing.policyType,
        quoteStatus: BOUND,
        applicant: existing.applicant,
        riskDetails: existing.riskDetails,
        proposedCoverages: existing.proposedCoverages,
        estimatedAnnualPremium: existing.estimatedAnnualPremium,
        estimatedMonthlyPremium: existing.estimatedMonthlyPremium,
        quoteValidUntil: existing.quoteValidUntil,
        boundPolicyId: newPolicyId,
        createdAt: existing.createdAt,
        updatedAt: now
    };
    Quote clonedBoundQuote = boundQuote.clone();
    lock {
        quoteStore[quoteId] = clonedBoundQuote.clone();
    }
    return newPolicy;
}

isolated function expireQuote(string quoteId) returns Quote? {
    Quote? existing = getQuoteById(quoteId);
    if existing is () {
        return ();
    }
    string now = currentTimestamp();
    Quote expired = {
        quoteId: existing.quoteId,
        quoteNumber: existing.quoteNumber,
        policyType: existing.policyType,
        quoteStatus: EXPIRED,
        applicant: existing.applicant,
        riskDetails: existing.riskDetails,
        proposedCoverages: existing.proposedCoverages,
        estimatedAnnualPremium: existing.estimatedAnnualPremium,
        estimatedMonthlyPremium: existing.estimatedMonthlyPremium,
        quoteValidUntil: existing.quoteValidUntil,
        boundPolicyId: existing.boundPolicyId,
        createdAt: existing.createdAt,
        updatedAt: now
    };
    Quote clonedExpired = expired.clone();
    lock {
        quoteStore[quoteId] = clonedExpired.clone();
    }
    return expired;
}

isolated function buildError(string code, string msg) returns ErrorResponse {
    return {errorCode: code, message: msg, timestamp: currentTimestamp()};
}

isolated function buildSuccess(string msg) returns SuccessResponse {
    return {message: msg, timestamp: currentTimestamp()};
}
