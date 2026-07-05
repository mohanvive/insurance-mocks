// ─── Claim helper functions ───────────────────────────────────────────────────

isolated function getAllClaims(string? policyId, string? claimType, string? status, int page, int pageSize)
        returns ClaimListResponse {
    Claim[] filtered;
    lock {
        Claim[] temp = [];
        foreach Claim clm in claimStore {
            boolean policyMatch = policyId is () || clm.policyId == policyId;
            boolean typeMatch = claimType is () || clm.claimType == claimType;
            boolean statusMatch = status is () || clm.claimStatus == status;
            if policyMatch && typeMatch && statusMatch {
                temp.push(clm.clone());
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
    Claim[] pageSlice = startIdx >= total ? [] : filtered.slice(startIdx, endIdx);
    return {total: total, page: page, pageSize: pageSize, claims: pageSlice};
}

isolated function getClaimById(string claimId) returns Claim? {
    lock {
        Claim? clm = claimStore[claimId];
        if clm is Claim {
            return clm.clone();
        }
    }
    return ();
}

isolated function fileClaim(ClaimFileRequest req) returns Claim {
    string newId = generateId();
    string now = currentTimestamp();
    Claim newClaim = {
        claimId: newId,
        claimNumber: generateClaimNumber(),
        policyId: req.policyId,
        policyNumber: req.policyNumber,
        claimType: req.claimType,
        claimStatus: SUBMITTED,
        claimant: req.claimant,
        lossDate: req.lossDate,
        reportedDate: now.substring(0, 10),
        lossLocation: req.lossLocation,
        lossDescription: req.lossDescription,
        estimatedLossAmount: req.estimatedLossAmount,
        approvedAmount: 0.00d,
        deductibleAmount: 0.00d,
        damagedVehicle: req.damagedVehicle,
        assignedAdjusterId: (),
        assignedAdjusterName: (),
        notes: [],
        documents: [],
        payments: [],
        closedDate: (),
        denialReason: (),
        createdAt: now,
        updatedAt: now
    };
    Claim clonedClaim = newClaim.clone();
    lock {
        claimStore[newId] = clonedClaim.clone();
    }
    return newClaim;
}

isolated function updateClaim(string claimId, ClaimUpdateRequest req) returns Claim? {
    Claim? existing = getClaimById(claimId);
    if existing is () {
        return ();
    }
    ClaimStatus? newStatus = req.claimStatus;
    decimal? newEstimated = req.estimatedLossAmount;
    decimal? newApproved = req.approvedAmount;
    decimal? newDeductible = req.deductibleAmount;
    string? newAdjId = req.assignedAdjusterId;
    string? newAdjName = req.assignedAdjusterName;
    string? newDenialReason = req.denialReason;

    Claim updated = {
        claimId: existing.claimId,
        claimNumber: existing.claimNumber,
        policyId: existing.policyId,
        policyNumber: existing.policyNumber,
        claimType: existing.claimType,
        claimStatus: newStatus is ClaimStatus ? newStatus : existing.claimStatus,
        claimant: existing.claimant,
        lossDate: existing.lossDate,
        reportedDate: existing.reportedDate,
        lossLocation: existing.lossLocation,
        lossDescription: existing.lossDescription,
        estimatedLossAmount: newEstimated is decimal ? newEstimated : existing.estimatedLossAmount,
        approvedAmount: newApproved is decimal ? newApproved : existing.approvedAmount,
        deductibleAmount: newDeductible is decimal ? newDeductible : existing.deductibleAmount,
        damagedVehicle: existing.damagedVehicle,
        assignedAdjusterId: newAdjId is string ? newAdjId : existing.assignedAdjusterId,
        assignedAdjusterName: newAdjName is string ? newAdjName : existing.assignedAdjusterName,
        notes: existing.notes,
        documents: existing.documents,
        payments: existing.payments,
        closedDate: existing.closedDate,
        denialReason: newDenialReason is string ? newDenialReason : existing.denialReason,
        createdAt: existing.createdAt,
        updatedAt: currentTimestamp()
    };
    Claim clonedUpdated = updated.clone();
    lock {
        claimStore[claimId] = clonedUpdated.clone();
    }
    return updated;
}

isolated function closeClaim(string claimId, ClaimCloseRequest req) returns Claim? {
    Claim? existing = getClaimById(claimId);
    if existing is () {
        return ();
    }
    string now = currentTimestamp();
    Claim closed = {
        claimId: existing.claimId,
        claimNumber: existing.claimNumber,
        policyId: existing.policyId,
        policyNumber: existing.policyNumber,
        claimType: existing.claimType,
        claimStatus: CLOSED,
        claimant: existing.claimant,
        lossDate: existing.lossDate,
        reportedDate: existing.reportedDate,
        lossLocation: existing.lossLocation,
        lossDescription: existing.lossDescription,
        estimatedLossAmount: existing.estimatedLossAmount,
        approvedAmount: existing.approvedAmount,
        deductibleAmount: existing.deductibleAmount,
        damagedVehicle: existing.damagedVehicle,
        assignedAdjusterId: existing.assignedAdjusterId,
        assignedAdjusterName: existing.assignedAdjusterName,
        notes: existing.notes,
        documents: existing.documents,
        payments: existing.payments,
        closedDate: req.closedDate,
        denialReason: existing.denialReason,
        createdAt: existing.createdAt,
        updatedAt: now
    };
    Claim clonedClosed = closed.clone();
    lock {
        claimStore[claimId] = clonedClosed.clone();
    }
    return closed;
}

isolated function reopenClaim(string claimId) returns Claim? {
    Claim? existing = getClaimById(claimId);
    if existing is () {
        return ();
    }
    string now = currentTimestamp();
    Claim reopened = {
        claimId: existing.claimId,
        claimNumber: existing.claimNumber,
        policyId: existing.policyId,
        policyNumber: existing.policyNumber,
        claimType: existing.claimType,
        claimStatus: REOPENED,
        claimant: existing.claimant,
        lossDate: existing.lossDate,
        reportedDate: existing.reportedDate,
        lossLocation: existing.lossLocation,
        lossDescription: existing.lossDescription,
        estimatedLossAmount: existing.estimatedLossAmount,
        approvedAmount: existing.approvedAmount,
        deductibleAmount: existing.deductibleAmount,
        damagedVehicle: existing.damagedVehicle,
        assignedAdjusterId: existing.assignedAdjusterId,
        assignedAdjusterName: existing.assignedAdjusterName,
        notes: existing.notes,
        documents: existing.documents,
        payments: existing.payments,
        closedDate: (),
        denialReason: existing.denialReason,
        createdAt: existing.createdAt,
        updatedAt: now
    };
    Claim clonedReopened = reopened.clone();
    lock {
        claimStore[claimId] = clonedReopened.clone();
    }
    return reopened;
}

// ─── Note helper functions ────────────────────────────────────────────────────

isolated function addNote(string claimId, ClaimNoteRequest req) returns ClaimNote? {
    Claim? existing = getClaimById(claimId);
    if existing is () {
        return ();
    }
    string newNoteId = generateId();
    string now = currentTimestamp();
    ClaimNote newNote = {
        noteId: newNoteId,
        claimId: claimId,
        authorId: req.authorId,
        authorName: req.authorName,
        noteText: req.noteText,
        createdAt: now
    };
    ClaimNote clonedNote = newNote.clone();
    ClaimNote[] updatedNotes = existing.notes.clone();
    updatedNotes.push(clonedNote);

    Claim updated = {
        claimId: existing.claimId,
        claimNumber: existing.claimNumber,
        policyId: existing.policyId,
        policyNumber: existing.policyNumber,
        claimType: existing.claimType,
        claimStatus: existing.claimStatus,
        claimant: existing.claimant,
        lossDate: existing.lossDate,
        reportedDate: existing.reportedDate,
        lossLocation: existing.lossLocation,
        lossDescription: existing.lossDescription,
        estimatedLossAmount: existing.estimatedLossAmount,
        approvedAmount: existing.approvedAmount,
        deductibleAmount: existing.deductibleAmount,
        damagedVehicle: existing.damagedVehicle,
        assignedAdjusterId: existing.assignedAdjusterId,
        assignedAdjusterName: existing.assignedAdjusterName,
        notes: updatedNotes,
        documents: existing.documents,
        payments: existing.payments,
        closedDate: existing.closedDate,
        denialReason: existing.denialReason,
        createdAt: existing.createdAt,
        updatedAt: now
    };
    Claim clonedUpdated = updated.clone();
    lock {
        claimStore[claimId] = clonedUpdated.clone();
    }
    return newNote;
}

// ─── Document helper functions ────────────────────────────────────────────────

isolated function addDocument(string claimId, ClaimDocumentRequest req) returns ClaimDocument? {
    Claim? existing = getClaimById(claimId);
    if existing is () {
        return ();
    }
    string newDocId = generateId();
    string now = currentTimestamp();
    ClaimDocument newDoc = {
        documentId: newDocId,
        claimId: claimId,
        documentType: req.documentType,
        fileName: req.fileName,
        fileUrl: req.fileUrl,
        uploadedBy: req.uploadedBy,
        uploadedAt: now
    };
    ClaimDocument clonedDoc = newDoc.clone();
    ClaimDocument[] updatedDocs = existing.documents.clone();
    updatedDocs.push(clonedDoc);

    Claim updated = {
        claimId: existing.claimId,
        claimNumber: existing.claimNumber,
        policyId: existing.policyId,
        policyNumber: existing.policyNumber,
        claimType: existing.claimType,
        claimStatus: existing.claimStatus,
        claimant: existing.claimant,
        lossDate: existing.lossDate,
        reportedDate: existing.reportedDate,
        lossLocation: existing.lossLocation,
        lossDescription: existing.lossDescription,
        estimatedLossAmount: existing.estimatedLossAmount,
        approvedAmount: existing.approvedAmount,
        deductibleAmount: existing.deductibleAmount,
        damagedVehicle: existing.damagedVehicle,
        assignedAdjusterId: existing.assignedAdjusterId,
        assignedAdjusterName: existing.assignedAdjusterName,
        notes: existing.notes,
        documents: updatedDocs,
        payments: existing.payments,
        closedDate: existing.closedDate,
        denialReason: existing.denialReason,
        createdAt: existing.createdAt,
        updatedAt: now
    };
    Claim clonedUpdated = updated.clone();
    lock {
        claimStore[claimId] = clonedUpdated.clone();
    }
    return newDoc;
}

isolated function removeDocument(string claimId, string documentId) returns boolean {
    Claim? existing = getClaimById(claimId);
    if existing is () {
        return false;
    }
    ClaimDocument[] currentDocs = existing.documents.clone();
    int? foundIdx = ();
    foreach int i in 0 ..< currentDocs.length() {
        if currentDocs[i].documentId == documentId {
            foundIdx = i;
        }
    }
    int? idx = foundIdx;
    if idx is () {
        return false;
    }
    _ = currentDocs.remove(idx);
    string now = currentTimestamp();
    Claim updated = {
        claimId: existing.claimId,
        claimNumber: existing.claimNumber,
        policyId: existing.policyId,
        policyNumber: existing.policyNumber,
        claimType: existing.claimType,
        claimStatus: existing.claimStatus,
        claimant: existing.claimant,
        lossDate: existing.lossDate,
        reportedDate: existing.reportedDate,
        lossLocation: existing.lossLocation,
        lossDescription: existing.lossDescription,
        estimatedLossAmount: existing.estimatedLossAmount,
        approvedAmount: existing.approvedAmount,
        deductibleAmount: existing.deductibleAmount,
        damagedVehicle: existing.damagedVehicle,
        assignedAdjusterId: existing.assignedAdjusterId,
        assignedAdjusterName: existing.assignedAdjusterName,
        notes: existing.notes,
        documents: currentDocs,
        payments: existing.payments,
        closedDate: existing.closedDate,
        denialReason: existing.denialReason,
        createdAt: existing.createdAt,
        updatedAt: now
    };
    Claim clonedUpdated = updated.clone();
    lock {
        claimStore[claimId] = clonedUpdated.clone();
    }
    return true;
}

// ─── Payment helper functions ─────────────────────────────────────────────────

isolated function addPayment(string claimId, ClaimPaymentRequest req) returns ClaimPayment? {
    Claim? existing = getClaimById(claimId);
    if existing is () {
        return ();
    }
    string newPayId = generateId();
    string now = currentTimestamp();
    ClaimPayment newPayment = {
        paymentId: newPayId,
        claimId: claimId,
        paymentAmount: req.paymentAmount,
        paymentMethod: req.paymentMethod,
        paymentStatus: PENDING,
        payeeName: req.payeeName,
        payeeAccountRef: req.payeeAccountRef,
        description: req.description,
        processedAt: (),
        createdAt: now
    };
    ClaimPayment clonedPayment = newPayment.clone();
    ClaimPayment[] updatedPayments = existing.payments.clone();
    updatedPayments.push(clonedPayment);

    Claim updated = {
        claimId: existing.claimId,
        claimNumber: existing.claimNumber,
        policyId: existing.policyId,
        policyNumber: existing.policyNumber,
        claimType: existing.claimType,
        claimStatus: existing.claimStatus,
        claimant: existing.claimant,
        lossDate: existing.lossDate,
        reportedDate: existing.reportedDate,
        lossLocation: existing.lossLocation,
        lossDescription: existing.lossDescription,
        estimatedLossAmount: existing.estimatedLossAmount,
        approvedAmount: existing.approvedAmount,
        deductibleAmount: existing.deductibleAmount,
        damagedVehicle: existing.damagedVehicle,
        assignedAdjusterId: existing.assignedAdjusterId,
        assignedAdjusterName: existing.assignedAdjusterName,
        notes: existing.notes,
        documents: existing.documents,
        payments: updatedPayments,
        closedDate: existing.closedDate,
        denialReason: existing.denialReason,
        createdAt: existing.createdAt,
        updatedAt: now
    };
    Claim clonedUpdated = updated.clone();
    lock {
        claimStore[claimId] = clonedUpdated.clone();
    }
    return newPayment;
}

// ─── Common response builders ─────────────────────────────────────────────────

isolated function buildError(string code, string msg) returns ErrorResponse {
    return {errorCode: code, message: msg, timestamp: currentTimestamp()};
}

isolated function buildSuccess(string msg) returns SuccessResponse {
    return {message: msg, timestamp: currentTimestamp()};
}
