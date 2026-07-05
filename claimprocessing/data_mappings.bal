import ballerina/time;
import ballerina/uuid;

// ─── In-memory store ──────────────────────────────────────────────────────────

isolated map<Claim> claimStore = {};

// ─── Utility functions ────────────────────────────────────────────────────────

isolated function generateId() returns string {
    return uuid:createType4AsString();
}

isolated function currentTimestamp() returns string {
    time:Utc utcNow = time:utcNow();
    return time:utcToString(utcNow);
}

isolated function generateClaimNumber() returns string {
    string uid = uuid:createType4AsString();
    string shortId = uid.substring(0, 8).toUpperAscii();
    return string `CLM-${shortId}`;
}

// ─── Seed data initializer ────────────────────────────────────────────────────

function initSeedData() {
    string now = currentTimestamp();

    // Claim 1 – AUTO_COLLISION, APPROVED, pol-001 (Alice Johnson)
    Claim claim1 = {
        claimId: "clm-001",
        claimNumber: "CLM-AUTO001",
        policyId: "pol-001",
        policyNumber: "POL-AUTO001",
        claimType: AUTO_COLLISION,
        claimStatus: APPROVED,
        claimant: {
            customerId: "cust-001",
            firstName: "Alice",
            lastName: "Johnson",
            email: "alice.johnson@example.com",
            phoneNumber: "+1-555-0101"
        },
        lossDate: "2025-11-10",
        reportedDate: "2025-11-11",
        lossLocation: {
            streetLine1: "I-55 Northbound Mile Marker 42",
            city: "Springfield",
            state: "IL",
            zipCode: "62701",
            country: "US"
        },
        lossDescription: "Rear-end collision on the highway. Vehicle sustained significant damage to the rear bumper and trunk.",
        estimatedLossAmount: 8500.00d,
        approvedAmount: 7500.00d,
        deductibleAmount: 1000.00d,
        damagedVehicle: {
            vin: "1HGBH41JXMN109186",
            make: "Honda",
            model: "Civic",
            year: 2022,
            licensePlate: "IL-ABC123",
            damageDescription: "Rear bumper crushed, trunk lid bent, tail lights broken"
        },
        assignedAdjusterId: "adj-001",
        assignedAdjusterName: "Tom Bradley",
        notes: [
            {
                noteId: "note-001",
                claimId: "clm-001",
                authorId: "adj-001",
                authorName: "Tom Bradley",
                noteText: "Inspection completed. Damage consistent with reported collision. Approved for repair.",
                createdAt: "2025-11-15T10:00:00Z"
            }
        ],
        documents: [
            {
                documentId: "doc-001",
                claimId: "clm-001",
                documentType: POLICE_REPORT,
                fileName: "police_report_clm001.pdf",
                fileUrl: "https://docs.example.com/clm-001/police_report.pdf",
                uploadedBy: "alice.johnson@example.com",
                uploadedAt: "2025-11-11T09:00:00Z"
            },
            {
                documentId: "doc-002",
                claimId: "clm-001",
                documentType: PHOTOS,
                fileName: "damage_photos_clm001.zip",
                fileUrl: "https://docs.example.com/clm-001/photos.zip",
                uploadedBy: "alice.johnson@example.com",
                uploadedAt: "2025-11-11T09:30:00Z"
            }
        ],
        payments: [
            {
                paymentId: "pay-001",
                claimId: "clm-001",
                paymentAmount: 6500.00d,
                paymentMethod: BANK_TRANSFER,
                paymentStatus: PROCESSED,
                payeeName: "Springfield Auto Repair",
                payeeAccountRef: "ACC-78901",
                description: "Repair settlement payment",
                processedAt: "2025-11-20T14:00:00Z",
                createdAt: "2025-11-18T10:00:00Z"
            }
        ],
        closedDate: (),
        denialReason: (),
        createdAt: now,
        updatedAt: now
    };

    // Claim 2 – PROPERTY_DAMAGE, UNDER_REVIEW, pol-002 (Bob Martinez)
    Claim claim2 = {
        claimId: "clm-002",
        claimNumber: "CLM-HOME001",
        policyId: "pol-002",
        policyNumber: "POL-HOME001",
        claimType: PROPERTY_DAMAGE,
        claimStatus: UNDER_REVIEW,
        claimant: {
            customerId: "cust-002",
            firstName: "Bob",
            lastName: "Martinez",
            email: "bob.martinez@example.com",
            phoneNumber: "+1-555-0202"
        },
        lossDate: "2026-01-05",
        reportedDate: "2026-01-06",
        lossLocation: {
            streetLine1: "456 Oak Avenue",
            city: "Austin",
            state: "TX",
            zipCode: "73301",
            country: "US"
        },
        lossDescription: "Hailstorm caused significant damage to the roof and gutters. Multiple shingles missing.",
        estimatedLossAmount: 15000.00d,
        approvedAmount: 0.00d,
        deductibleAmount: 2000.00d,
        damagedVehicle: (),
        assignedAdjusterId: "adj-002",
        assignedAdjusterName: "Sandra Mills",
        notes: [
            {
                noteId: "note-002",
                claimId: "clm-002",
                authorId: "adj-002",
                authorName: "Sandra Mills",
                noteText: "Initial inspection scheduled for next week. Contractor estimate requested.",
                createdAt: "2026-01-08T11:00:00Z"
            }
        ],
        documents: [
            {
                documentId: "doc-003",
                claimId: "clm-002",
                documentType: PHOTOS,
                fileName: "hail_damage_photos.zip",
                fileUrl: "https://docs.example.com/clm-002/photos.zip",
                uploadedBy: "bob.martinez@example.com",
                uploadedAt: "2026-01-06T15:00:00Z"
            },
            {
                documentId: "doc-004",
                claimId: "clm-002",
                documentType: REPAIR_ESTIMATE,
                fileName: "roofing_estimate.pdf",
                fileUrl: "https://docs.example.com/clm-002/estimate.pdf",
                uploadedBy: "bob.martinez@example.com",
                uploadedAt: "2026-01-07T10:00:00Z"
            }
        ],
        payments: [],
        closedDate: (),
        denialReason: (),
        createdAt: now,
        updatedAt: now
    };

    // Claim 3 – GENERAL_LIABILITY, DENIED, pol-007 (Hannah Patel)
    Claim claim3 = {
        claimId: "clm-003",
        claimNumber: "CLM-COM001",
        policyId: "pol-007",
        policyNumber: "POL-COM002",
        claimType: GENERAL_LIABILITY,
        claimStatus: DENIED,
        claimant: {
            customerId: "cust-009",
            firstName: "Hannah",
            lastName: "Patel",
            email: "hannah.patel@example.com",
            phoneNumber: "+1-555-0909"
        },
        lossDate: "2025-12-01",
        reportedDate: "2025-12-03",
        lossLocation: {
            streetLine1: "1010 Commerce Park",
            city: "Dallas",
            state: "TX",
            zipCode: "75201",
            country: "US"
        },
        lossDescription: "Third-party slip and fall incident in the warehouse loading dock area.",
        estimatedLossAmount: 50000.00d,
        approvedAmount: 0.00d,
        deductibleAmount: 10000.00d,
        damagedVehicle: (),
        assignedAdjusterId: "adj-003",
        assignedAdjusterName: "James Carter",
        notes: [
            {
                noteId: "note-003",
                claimId: "clm-003",
                authorId: "adj-003",
                authorName: "James Carter",
                noteText: "Investigation revealed the incident occurred outside policy coverage hours. Claim denied.",
                createdAt: "2025-12-15T09:00:00Z"
            }
        ],
        documents: [
            {
                documentId: "doc-005",
                claimId: "clm-003",
                documentType: WITNESS_STATEMENT,
                fileName: "witness_statement.pdf",
                fileUrl: "https://docs.example.com/clm-003/witness.pdf",
                uploadedBy: "hannah.patel@example.com",
                uploadedAt: "2025-12-04T08:00:00Z"
            }
        ],
        payments: [],
        closedDate: "2025-12-20",
        denialReason: "Incident occurred outside the covered business hours specified in the policy.",
        createdAt: now,
        updatedAt: now
    };

    // Claim 4 – THEFT, SUBMITTED, pol-004 (Daniel Park)
    Claim claim4 = {
        claimId: "clm-004",
        claimNumber: "CLM-REN001",
        policyId: "pol-004",
        policyNumber: "POL-REN001",
        claimType: THEFT,
        claimStatus: SUBMITTED,
        claimant: {
            customerId: "cust-006",
            firstName: "Daniel",
            lastName: "Park",
            email: "daniel.park@example.com",
            phoneNumber: "+1-555-0606"
        },
        lossDate: "2026-03-10",
        reportedDate: "2026-03-10",
        lossLocation: {
            streetLine1: "22 Birch Lane",
            streetLine2: "Apt 3C",
            city: "Portland",
            state: "OR",
            zipCode: "97201",
            country: "US"
        },
        lossDescription: "Laptop, camera equipment, and jewelry stolen during apartment break-in.",
        estimatedLossAmount: 4800.00d,
        approvedAmount: 0.00d,
        deductibleAmount: 250.00d,
        damagedVehicle: (),
        assignedAdjusterId: (),
        assignedAdjusterName: (),
        notes: [],
        documents: [
            {
                documentId: "doc-006",
                claimId: "clm-004",
                documentType: POLICE_REPORT,
                fileName: "theft_police_report.pdf",
                fileUrl: "https://docs.example.com/clm-004/police_report.pdf",
                uploadedBy: "daniel.park@example.com",
                uploadedAt: "2026-03-10T18:00:00Z"
            }
        ],
        payments: [],
        closedDate: (),
        denialReason: (),
        createdAt: now,
        updatedAt: now
    };

    // Claim 5 – WATER_DAMAGE, INVESTIGATION, pol-006 (George Nguyen)
    Claim claim5 = {
        claimId: "clm-005",
        claimNumber: "CLM-HOME002",
        policyId: "pol-006",
        policyNumber: "POL-HOME002",
        claimType: WATER_DAMAGE,
        claimStatus: INVESTIGATION,
        claimant: {
            customerId: "cust-008",
            firstName: "George",
            lastName: "Nguyen",
            email: "george.nguyen@example.com",
            phoneNumber: "+1-555-0808"
        },
        lossDate: "2026-02-14",
        reportedDate: "2026-02-15",
        lossLocation: {
            streetLine1: "500 Cedar Drive",
            city: "Miami",
            state: "FL",
            zipCode: "33101",
            country: "US"
        },
        lossDescription: "Burst pipe in the master bathroom caused flooding in the bathroom and adjacent bedroom.",
        estimatedLossAmount: 22000.00d,
        approvedAmount: 0.00d,
        deductibleAmount: 3000.00d,
        damagedVehicle: (),
        assignedAdjusterId: "adj-002",
        assignedAdjusterName: "Sandra Mills",
        notes: [
            {
                noteId: "note-004",
                claimId: "clm-005",
                authorId: "adj-002",
                authorName: "Sandra Mills",
                noteText: "Plumber's report obtained. Investigating whether damage is covered under sudden and accidental clause.",
                createdAt: "2026-02-20T13:00:00Z"
            }
        ],
        documents: [
            {
                documentId: "doc-007",
                claimId: "clm-005",
                documentType: PHOTOS,
                fileName: "water_damage_photos.zip",
                fileUrl: "https://docs.example.com/clm-005/photos.zip",
                uploadedBy: "george.nguyen@example.com",
                uploadedAt: "2026-02-15T10:00:00Z"
            },
            {
                documentId: "doc-008",
                claimId: "clm-005",
                documentType: REPAIR_ESTIMATE,
                fileName: "restoration_estimate.pdf",
                fileUrl: "https://docs.example.com/clm-005/estimate.pdf",
                uploadedBy: "george.nguyen@example.com",
                uploadedAt: "2026-02-17T09:00:00Z"
            }
        ],
        payments: [],
        closedDate: (),
        denialReason: (),
        createdAt: now,
        updatedAt: now
    };

    // Claim 6 – AUTO_COMPREHENSIVE, CLOSED, pol-001 (Alice Johnson)
    Claim claim6 = {
        claimId: "clm-006",
        claimNumber: "CLM-AUTO002",
        policyId: "pol-001",
        policyNumber: "POL-AUTO001",
        claimType: AUTO_COMPREHENSIVE,
        claimStatus: CLOSED,
        claimant: {
            customerId: "cust-001",
            firstName: "Alice",
            lastName: "Johnson",
            email: "alice.johnson@example.com",
            phoneNumber: "+1-555-0101"
        },
        lossDate: "2025-08-20",
        reportedDate: "2025-08-21",
        lossLocation: {
            streetLine1: "123 Maple Street",
            city: "Springfield",
            state: "IL",
            zipCode: "62701",
            country: "US"
        },
        lossDescription: "Windshield cracked by falling tree branch during storm.",
        estimatedLossAmount: 1200.00d,
        approvedAmount: 700.00d,
        deductibleAmount: 500.00d,
        damagedVehicle: {
            vin: "1HGBH41JXMN109186",
            make: "Honda",
            model: "Civic",
            year: 2022,
            licensePlate: "IL-ABC123",
            damageDescription: "Windshield cracked from top-left to bottom-right"
        },
        assignedAdjusterId: "adj-001",
        assignedAdjusterName: "Tom Bradley",
        notes: [
            {
                noteId: "note-005",
                claimId: "clm-006",
                authorId: "adj-001",
                authorName: "Tom Bradley",
                noteText: "Windshield replacement completed. Claim settled and closed.",
                createdAt: "2025-08-28T11:00:00Z"
            }
        ],
        documents: [
            {
                documentId: "doc-009",
                claimId: "clm-006",
                documentType: PHOTOS,
                fileName: "windshield_damage.jpg",
                fileUrl: "https://docs.example.com/clm-006/photos.jpg",
                uploadedBy: "alice.johnson@example.com",
                uploadedAt: "2025-08-21T08:00:00Z"
            },
            {
                documentId: "doc-010",
                claimId: "clm-006",
                documentType: INVOICE,
                fileName: "windshield_invoice.pdf",
                fileUrl: "https://docs.example.com/clm-006/invoice.pdf",
                uploadedBy: "adj-001",
                uploadedAt: "2025-08-27T14:00:00Z"
            }
        ],
        payments: [
            {
                paymentId: "pay-002",
                claimId: "clm-006",
                paymentAmount: 700.00d,
                paymentMethod: CHECK,
                paymentStatus: PROCESSED,
                payeeName: "Alice Johnson",
                payeeAccountRef: (),
                description: "Windshield replacement reimbursement",
                processedAt: "2025-08-29T10:00:00Z",
                createdAt: "2025-08-28T15:00:00Z"
            }
        ],
        closedDate: "2025-08-30",
        denialReason: (),
        createdAt: now,
        updatedAt: now
    };

    // Claim 7 – FIRE, PARTIALLY_APPROVED, pol-010 (Kevin Okafor)
    Claim claim7 = {
        claimId: "clm-007",
        claimNumber: "CLM-HOME003",
        policyId: "pol-010",
        policyNumber: "POL-HOME003",
        claimType: FIRE,
        claimStatus: PARTIALLY_APPROVED,
        claimant: {
            customerId: "cust-012",
            firstName: "Kevin",
            lastName: "Okafor",
            email: "kevin.okafor@example.com",
            phoneNumber: "+1-555-1212"
        },
        lossDate: "2026-04-02",
        reportedDate: "2026-04-02",
        lossLocation: {
            streetLine1: "250 Redwood Blvd",
            city: "Atlanta",
            state: "GA",
            zipCode: "30301",
            country: "US"
        },
        lossDescription: "Kitchen fire caused by electrical fault. Damage to kitchen cabinets, appliances, and ceiling.",
        estimatedLossAmount: 35000.00d,
        approvedAmount: 28000.00d,
        deductibleAmount: 2000.00d,
        damagedVehicle: (),
        assignedAdjusterId: "adj-004",
        assignedAdjusterName: "Maria Lopez",
        notes: [
            {
                noteId: "note-006",
                claimId: "clm-007",
                authorId: "adj-004",
                authorName: "Maria Lopez",
                noteText: "Fire investigation confirmed electrical fault. Some personal property items not covered under dwelling coverage.",
                createdAt: "2026-04-10T09:00:00Z"
            }
        ],
        documents: [
            {
                documentId: "doc-011",
                claimId: "clm-007",
                documentType: PHOTOS,
                fileName: "fire_damage_photos.zip",
                fileUrl: "https://docs.example.com/clm-007/photos.zip",
                uploadedBy: "kevin.okafor@example.com",
                uploadedAt: "2026-04-03T08:00:00Z"
            },
            {
                documentId: "doc-012",
                claimId: "clm-007",
                documentType: REPAIR_ESTIMATE,
                fileName: "fire_restoration_estimate.pdf",
                fileUrl: "https://docs.example.com/clm-007/estimate.pdf",
                uploadedBy: "kevin.okafor@example.com",
                uploadedAt: "2026-04-05T10:00:00Z"
            }
        ],
        payments: [
            {
                paymentId: "pay-003",
                claimId: "clm-007",
                paymentAmount: 26000.00d,
                paymentMethod: DIRECT_DEPOSIT,
                paymentStatus: PROCESSED,
                payeeName: "Kevin Okafor",
                payeeAccountRef: "ACC-55432",
                description: "Partial settlement – kitchen restoration",
                processedAt: "2026-04-20T12:00:00Z",
                createdAt: "2026-04-18T09:00:00Z"
            }
        ],
        closedDate: (),
        denialReason: (),
        createdAt: now,
        updatedAt: now
    };

    // Claim 8 – AUTO_LIABILITY, SUBMITTED, pol-001 (Alice Johnson)
    Claim claim8 = {
        claimId: "clm-008",
        claimNumber: "CLM-AUTO003",
        policyId: "pol-001",
        policyNumber: "POL-AUTO001",
        claimType: AUTO_LIABILITY,
        claimStatus: SUBMITTED,
        claimant: {
            customerId: "cust-001",
            firstName: "Alice",
            lastName: "Johnson",
            email: "alice.johnson@example.com",
            phoneNumber: "+1-555-0101"
        },
        lossDate: "2026-05-18",
        reportedDate: "2026-05-18",
        lossLocation: {
            streetLine1: "Oak Street & 5th Ave Intersection",
            city: "Springfield",
            state: "IL",
            zipCode: "62701",
            country: "US"
        },
        lossDescription: "Insured vehicle struck a pedestrian at a crosswalk. Third-party bodily injury claim filed.",
        estimatedLossAmount: 75000.00d,
        approvedAmount: 0.00d,
        deductibleAmount: 500.00d,
        damagedVehicle: {
            vin: "1HGBH41JXMN109186",
            make: "Honda",
            model: "Civic",
            year: 2022,
            licensePlate: "IL-ABC123",
            damageDescription: "Minor front bumper damage"
        },
        assignedAdjusterId: (),
        assignedAdjusterName: (),
        notes: [],
        documents: [
            {
                documentId: "doc-013",
                claimId: "clm-008",
                documentType: POLICE_REPORT,
                fileName: "accident_report_clm008.pdf",
                fileUrl: "https://docs.example.com/clm-008/police_report.pdf",
                uploadedBy: "alice.johnson@example.com",
                uploadedAt: "2026-05-18T20:00:00Z"
            }
        ],
        payments: [],
        closedDate: (),
        denialReason: (),
        createdAt: now,
        updatedAt: now
    };

    // Claim 9 – PROPERTY_DAMAGE, REOPENED, pol-002 (Bob Martinez)
    Claim claim9 = {
        claimId: "clm-009",
        claimNumber: "CLM-HOME004",
        policyId: "pol-002",
        policyNumber: "POL-HOME001",
        claimType: PROPERTY_DAMAGE,
        claimStatus: REOPENED,
        claimant: {
            customerId: "cust-002",
            firstName: "Bob",
            lastName: "Martinez",
            email: "bob.martinez@example.com",
            phoneNumber: "+1-555-0202"
        },
        lossDate: "2025-06-15",
        reportedDate: "2025-06-16",
        lossLocation: {
            streetLine1: "456 Oak Avenue",
            city: "Austin",
            state: "TX",
            zipCode: "73301",
            country: "US"
        },
        lossDescription: "Fence and garden shed destroyed by fallen tree during thunderstorm.",
        estimatedLossAmount: 6500.00d,
        approvedAmount: 4000.00d,
        deductibleAmount: 500.00d,
        damagedVehicle: (),
        assignedAdjusterId: "adj-002",
        assignedAdjusterName: "Sandra Mills",
        notes: [
            {
                noteId: "note-007",
                claimId: "clm-009",
                authorId: "adj-002",
                authorName: "Sandra Mills",
                noteText: "Claim reopened. Insured provided additional contractor estimate showing higher repair costs.",
                createdAt: "2026-01-10T10:00:00Z"
            }
        ],
        documents: [
            {
                documentId: "doc-014",
                claimId: "clm-009",
                documentType: PHOTOS,
                fileName: "storm_damage_photos.zip",
                fileUrl: "https://docs.example.com/clm-009/photos.zip",
                uploadedBy: "bob.martinez@example.com",
                uploadedAt: "2025-06-16T09:00:00Z"
            },
            {
                documentId: "doc-015",
                claimId: "clm-009",
                documentType: REPAIR_ESTIMATE,
                fileName: "revised_estimate.pdf",
                fileUrl: "https://docs.example.com/clm-009/revised_estimate.pdf",
                uploadedBy: "bob.martinez@example.com",
                uploadedAt: "2026-01-09T14:00:00Z"
            }
        ],
        payments: [
            {
                paymentId: "pay-004",
                claimId: "clm-009",
                paymentAmount: 3500.00d,
                paymentMethod: CHECK,
                paymentStatus: PROCESSED,
                payeeName: "Bob Martinez",
                payeeAccountRef: (),
                description: "Initial settlement payment",
                processedAt: "2025-07-01T10:00:00Z",
                createdAt: "2025-06-28T09:00:00Z"
            }
        ],
        closedDate: (),
        denialReason: (),
        createdAt: now,
        updatedAt: now
    };

    // Claim 10 – THEFT, UNDER_REVIEW, pol-006 (George Nguyen)
    Claim claim10 = {
        claimId: "clm-010",
        claimNumber: "CLM-HOME005",
        policyId: "pol-006",
        policyNumber: "POL-HOME002",
        claimType: THEFT,
        claimStatus: UNDER_REVIEW,
        claimant: {
            customerId: "cust-008",
            firstName: "George",
            lastName: "Nguyen",
            email: "george.nguyen@example.com",
            phoneNumber: "+1-555-0808"
        },
        lossDate: "2026-06-01",
        reportedDate: "2026-06-02",
        lossLocation: {
            streetLine1: "500 Cedar Drive",
            city: "Miami",
            state: "FL",
            zipCode: "33101",
            country: "US"
        },
        lossDescription: "Home burglary. Electronics, jewelry, and cash stolen. No signs of forced entry.",
        estimatedLossAmount: 18000.00d,
        approvedAmount: 0.00d,
        deductibleAmount: 1000.00d,
        damagedVehicle: (),
        assignedAdjusterId: "adj-004",
        assignedAdjusterName: "Maria Lopez",
        notes: [
            {
                noteId: "note-008",
                claimId: "clm-010",
                authorId: "adj-004",
                authorName: "Maria Lopez",
                noteText: "Reviewing police report and security camera footage. Proof of ownership documents requested.",
                createdAt: "2026-06-05T11:00:00Z"
            }
        ],
        documents: [
            {
                documentId: "doc-016",
                claimId: "clm-010",
                documentType: POLICE_REPORT,
                fileName: "burglary_report.pdf",
                fileUrl: "https://docs.example.com/clm-010/police_report.pdf",
                uploadedBy: "george.nguyen@example.com",
                uploadedAt: "2026-06-02T14:00:00Z"
            }
        ],
        payments: [],
        closedDate: (),
        denialReason: (),
        createdAt: now,
        updatedAt: now
    };

    lock {
        claimStore["clm-001"] = claim1.clone();
        claimStore["clm-002"] = claim2.clone();
        claimStore["clm-003"] = claim3.clone();
        claimStore["clm-004"] = claim4.clone();
        claimStore["clm-005"] = claim5.clone();
        claimStore["clm-006"] = claim6.clone();
        claimStore["clm-007"] = claim7.clone();
        claimStore["clm-008"] = claim8.clone();
        claimStore["clm-009"] = claim9.clone();
        claimStore["clm-010"] = claim10.clone();
    }
}
