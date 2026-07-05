import ballerina/time;
import ballerina/uuid;

// ─── In-memory stores ─────────────────────────────────────────────────────────

isolated map<Policy> policyStore = {};
isolated map<Quote> quoteStore = {};

// ─── Utility functions ────────────────────────────────────────────────────────

isolated function generateId() returns string {
    return uuid:createType4AsString();
}

isolated function currentTimestamp() returns string {
    time:Utc utcNow = time:utcNow();
    return time:utcToString(utcNow);
}

isolated function generatePolicyNumber() returns string {
    string uid = uuid:createType4AsString();
    string shortId = uid.substring(0, 8).toUpperAscii();
    return string `POL-${shortId}`;
}

isolated function generateQuoteNumber() returns string {
    string uid = uuid:createType4AsString();
    string shortId = uid.substring(0, 8).toUpperAscii();
    return string `QTE-${shortId}`;
}

isolated function calculatePremium(Coverage[] coverages) returns decimal {
    decimal total = 0.0d;
    foreach Coverage cov in coverages {
        total += cov.premiumAmount;
    }
    return total;
}

// ─── Seed data initializer ────────────────────────────────────────────────────

function initSeedData() {
    string now = currentTimestamp();

    // Seed Policy 1 – AUTO
    Policy autoPolicy = {
        policyId: "pol-001",
        policyNumber: "POL-AUTO001",
        policyType: AUTO,
        policyStatus: ACTIVE,
        policyHolder: {
            customerId: "cust-001",
            firstName: "Alice",
            lastName: "Johnson",
            email: "alice.johnson@example.com",
            phoneNumber: "+1-555-0101",
            mailingAddress: {
                streetLine1: "123 Maple Street",
                city: "Springfield",
                state: "IL",
                zipCode: "62701",
                country: "US"
            }
        },
        effectiveDate: "2025-01-01",
        expirationDate: "2026-01-01",
        annualPremium: 1200.00d,
        coverages: [
            {
                coverageType: LIABILITY,
                limitAmount: 100000.00d,
                deductibleAmount: 500.00d,
                premiumAmount: 600.00d
            },
            {
                coverageType: COLLISION,
                limitAmount: 50000.00d,
                deductibleAmount: 1000.00d,
                premiumAmount: 400.00d
            },
            {
                coverageType: COMPREHENSIVE,
                limitAmount: 50000.00d,
                deductibleAmount: 500.00d,
                premiumAmount: 200.00d
            }
        ],
        insuredVehicle: {
            vin: "1HGBH41JXMN109186",
            make: "Honda",
            model: "Civic",
            year: 2022,
            licensePlate: "IL-ABC123"
        },
        insuredProperty: (),
        createdAt: now,
        updatedAt: now
    };

    // Seed Policy 2 – HOME
    Policy homePolicy = {
        policyId: "pol-002",
        policyNumber: "POL-HOME001",
        policyType: HOME,
        policyStatus: ACTIVE,
        policyHolder: {
            customerId: "cust-002",
            firstName: "Bob",
            lastName: "Martinez",
            email: "bob.martinez@example.com",
            phoneNumber: "+1-555-0202",
            mailingAddress: {
                streetLine1: "456 Oak Avenue",
                city: "Austin",
                state: "TX",
                zipCode: "73301",
                country: "US"
            }
        },
        effectiveDate: "2025-03-15",
        expirationDate: "2026-03-15",
        annualPremium: 1800.00d,
        coverages: [
            {
                coverageType: DWELLING,
                limitAmount: 300000.00d,
                deductibleAmount: 2000.00d,
                premiumAmount: 1200.00d
            },
            {
                coverageType: PERSONAL_PROPERTY,
                limitAmount: 75000.00d,
                deductibleAmount: 500.00d,
                premiumAmount: 400.00d
            },
            {
                coverageType: LIABILITY,
                limitAmount: 100000.00d,
                deductibleAmount: 0.00d,
                premiumAmount: 200.00d
            }
        ],
        insuredVehicle: (),
        insuredProperty: {
            propertyId: "prop-001",
            propertyAddress: {
                streetLine1: "456 Oak Avenue",
                city: "Austin",
                state: "TX",
                zipCode: "73301",
                country: "US"
            },
            propertyType: "Single Family Home",
            estimatedValue: 350000.00d
        },
        createdAt: now,
        updatedAt: now
    };

    // Seed Policy 3 – COMMERCIAL (CANCELLED)
    Policy commercialPolicy = {
        policyId: "pol-003",
        policyNumber: "POL-COM001",
        policyType: COMMERCIAL,
        policyStatus: CANCELLED,
        policyHolder: {
            customerId: "cust-003",
            firstName: "Carol",
            lastName: "Lee",
            email: "carol.lee@example.com",
            phoneNumber: "+1-555-0303",
            mailingAddress: {
                streetLine1: "789 Business Blvd",
                city: "Chicago",
                state: "IL",
                zipCode: "60601",
                country: "US"
            }
        },
        effectiveDate: "2024-06-01",
        expirationDate: "2025-06-01",
        annualPremium: 5000.00d,
        coverages: [
            {
                coverageType: GENERAL_LIABILITY,
                limitAmount: 1000000.00d,
                deductibleAmount: 5000.00d,
                premiumAmount: 3500.00d
            },
            {
                coverageType: PERSONAL_PROPERTY,
                limitAmount: 200000.00d,
                deductibleAmount: 2500.00d,
                premiumAmount: 1500.00d
            }
        ],
        insuredVehicle: (),
        insuredProperty: {
            propertyId: "prop-002",
            propertyAddress: {
                streetLine1: "789 Business Blvd",
                city: "Chicago",
                state: "IL",
                zipCode: "60601",
                country: "US"
            },
            propertyType: "Commercial Office",
            estimatedValue: 1200000.00d
        },
        createdAt: now,
        updatedAt: now
    };

    // Seed Policy 4 – RENTERS (ACTIVE)
    Policy rentersPolicy = {
        policyId: "pol-004",
        policyNumber: "POL-REN001",
        policyType: RENTERS,
        policyStatus: ACTIVE,
        policyHolder: {
            customerId: "cust-006",
            firstName: "Daniel",
            lastName: "Park",
            email: "daniel.park@example.com",
            phoneNumber: "+1-555-0606",
            mailingAddress: {
                streetLine1: "22 Birch Lane",
                streetLine2: "Apt 3C",
                city: "Portland",
                state: "OR",
                zipCode: "97201",
                country: "US"
            }
        },
        effectiveDate: "2025-05-01",
        expirationDate: "2026-05-01",
        annualPremium: 420.00d,
        coverages: [
            {
                coverageType: PERSONAL_PROPERTY,
                limitAmount: 30000.00d,
                deductibleAmount: 250.00d,
                premiumAmount: 280.00d
            },
            {
                coverageType: LIABILITY,
                limitAmount: 100000.00d,
                deductibleAmount: 0.00d,
                premiumAmount: 140.00d
            }
        ],
        insuredVehicle: (),
        insuredProperty: {
            propertyId: "prop-004",
            propertyAddress: {
                streetLine1: "22 Birch Lane",
                streetLine2: "Apt 3C",
                city: "Portland",
                state: "OR",
                zipCode: "97201",
                country: "US"
            },
            propertyType: "Apartment",
            estimatedValue: 30000.00d
        },
        createdAt: now,
        updatedAt: now
    };

    // Seed Policy 5 – AUTO (EXPIRED)
    Policy autoExpiredPolicy = {
        policyId: "pol-005",
        policyNumber: "POL-AUTO002",
        policyType: AUTO,
        policyStatus: EXPIRED,
        policyHolder: {
            customerId: "cust-007",
            firstName: "Fiona",
            lastName: "Chen",
            email: "fiona.chen@example.com",
            phoneNumber: "+1-555-0707",
            mailingAddress: {
                streetLine1: "88 Willow Way",
                city: "Phoenix",
                state: "AZ",
                zipCode: "85001",
                country: "US"
            }
        },
        effectiveDate: "2023-07-01",
        expirationDate: "2024-07-01",
        annualPremium: 980.00d,
        coverages: [
            {
                coverageType: LIABILITY,
                limitAmount: 50000.00d,
                deductibleAmount: 500.00d,
                premiumAmount: 480.00d
            },
            {
                coverageType: COLLISION,
                limitAmount: 25000.00d,
                deductibleAmount: 1000.00d,
                premiumAmount: 300.00d
            },
            {
                coverageType: COMPREHENSIVE,
                limitAmount: 25000.00d,
                deductibleAmount: 500.00d,
                premiumAmount: 200.00d
            }
        ],
        insuredVehicle: {
            vin: "5YJSA1DN5DFP14705",
            make: "Tesla",
            model: "Model S",
            year: 2020,
            licensePlate: "AZ-EV2020"
        },
        insuredProperty: (),
        createdAt: now,
        updatedAt: now
    };

    // Seed Policy 6 – HOME (ACTIVE)
    Policy homePolicyTwo = {
        policyId: "pol-006",
        policyNumber: "POL-HOME002",
        policyType: HOME,
        policyStatus: ACTIVE,
        policyHolder: {
            customerId: "cust-008",
            firstName: "George",
            lastName: "Nguyen",
            email: "george.nguyen@example.com",
            phoneNumber: "+1-555-0808",
            mailingAddress: {
                streetLine1: "500 Cedar Drive",
                city: "Miami",
                state: "FL",
                zipCode: "33101",
                country: "US"
            }
        },
        effectiveDate: "2025-06-01",
        expirationDate: "2026-06-01",
        annualPremium: 2400.00d,
        coverages: [
            {
                coverageType: DWELLING,
                limitAmount: 450000.00d,
                deductibleAmount: 3000.00d,
                premiumAmount: 1700.00d
            },
            {
                coverageType: PERSONAL_PROPERTY,
                limitAmount: 90000.00d,
                deductibleAmount: 1000.00d,
                premiumAmount: 500.00d
            },
            {
                coverageType: LIABILITY,
                limitAmount: 200000.00d,
                deductibleAmount: 0.00d,
                premiumAmount: 200.00d
            }
        ],
        insuredVehicle: (),
        insuredProperty: {
            propertyId: "prop-005",
            propertyAddress: {
                streetLine1: "500 Cedar Drive",
                city: "Miami",
                state: "FL",
                zipCode: "33101",
                country: "US"
            },
            propertyType: "Single Family Home",
            estimatedValue: 520000.00d
        },
        createdAt: now,
        updatedAt: now
    };

    // Seed Policy 7 – COMMERCIAL (ACTIVE)
    Policy commercialPolicyTwo = {
        policyId: "pol-007",
        policyNumber: "POL-COM002",
        policyType: COMMERCIAL,
        policyStatus: ACTIVE,
        policyHolder: {
            customerId: "cust-009",
            firstName: "Hannah",
            lastName: "Patel",
            email: "hannah.patel@example.com",
            phoneNumber: "+1-555-0909",
            mailingAddress: {
                streetLine1: "1010 Commerce Park",
                city: "Dallas",
                state: "TX",
                zipCode: "75201",
                country: "US"
            }
        },
        effectiveDate: "2025-04-01",
        expirationDate: "2026-04-01",
        annualPremium: 8500.00d,
        coverages: [
            {
                coverageType: GENERAL_LIABILITY,
                limitAmount: 2000000.00d,
                deductibleAmount: 10000.00d,
                premiumAmount: 6000.00d
            },
            {
                coverageType: PERSONAL_PROPERTY,
                limitAmount: 500000.00d,
                deductibleAmount: 5000.00d,
                premiumAmount: 2500.00d
            }
        ],
        insuredVehicle: (),
        insuredProperty: {
            propertyId: "prop-006",
            propertyAddress: {
                streetLine1: "1010 Commerce Park",
                city: "Dallas",
                state: "TX",
                zipCode: "75201",
                country: "US"
            },
            propertyType: "Warehouse",
            estimatedValue: 3000000.00d
        },
        createdAt: now,
        updatedAt: now
    };

    // Seed Policy 8 – AUTO (PENDING)
    Policy autoPendingPolicy = {
        policyId: "pol-008",
        policyNumber: "POL-AUTO003",
        policyType: AUTO,
        policyStatus: PENDING,
        policyHolder: {
            customerId: "cust-010",
            firstName: "Ivan",
            lastName: "Russo",
            email: "ivan.russo@example.com",
            phoneNumber: "+1-555-1010",
            mailingAddress: {
                streetLine1: "77 Spruce Court",
                city: "Boston",
                state: "MA",
                zipCode: "02101",
                country: "US"
            }
        },
        effectiveDate: "2026-08-01",
        expirationDate: "2027-08-01",
        annualPremium: 1450.00d,
        coverages: [
            {
                coverageType: LIABILITY,
                limitAmount: 100000.00d,
                deductibleAmount: 500.00d,
                premiumAmount: 700.00d
            },
            {
                coverageType: COLLISION,
                limitAmount: 40000.00d,
                deductibleAmount: 1000.00d,
                premiumAmount: 450.00d
            },
            {
                coverageType: COMPREHENSIVE,
                limitAmount: 40000.00d,
                deductibleAmount: 500.00d,
                premiumAmount: 300.00d
            }
        ],
        insuredVehicle: {
            vin: "WBA3A5G59DNP26082",
            make: "BMW",
            model: "3 Series",
            year: 2023,
            licensePlate: "MA-BMW23"
        },
        insuredProperty: (),
        createdAt: now,
        updatedAt: now
    };

    // Seed Policy 9 – RENTERS (CANCELLED)
    Policy rentersCancelledPolicy = {
        policyId: "pol-009",
        policyNumber: "POL-REN002",
        policyType: RENTERS,
        policyStatus: CANCELLED,
        policyHolder: {
            customerId: "cust-011",
            firstName: "Julia",
            lastName: "Santos",
            email: "julia.santos@example.com",
            phoneNumber: "+1-555-1111",
            mailingAddress: {
                streetLine1: "33 Aspen Ave",
                streetLine2: "Unit 7",
                city: "Las Vegas",
                state: "NV",
                zipCode: "89101",
                country: "US"
            }
        },
        effectiveDate: "2024-01-01",
        expirationDate: "2024-09-15",
        annualPremium: 360.00d,
        coverages: [
            {
                coverageType: PERSONAL_PROPERTY,
                limitAmount: 20000.00d,
                deductibleAmount: 250.00d,
                premiumAmount: 240.00d
            },
            {
                coverageType: LIABILITY,
                limitAmount: 50000.00d,
                deductibleAmount: 0.00d,
                premiumAmount: 120.00d
            }
        ],
        insuredVehicle: (),
        insuredProperty: {
            propertyId: "prop-007",
            propertyAddress: {
                streetLine1: "33 Aspen Ave",
                streetLine2: "Unit 7",
                city: "Las Vegas",
                state: "NV",
                zipCode: "89101",
                country: "US"
            },
            propertyType: "Apartment",
            estimatedValue: 20000.00d
        },
        createdAt: now,
        updatedAt: now
    };

    // Seed Policy 10 – HOME (ACTIVE)
    Policy homePolicyThree = {
        policyId: "pol-010",
        policyNumber: "POL-HOME003",
        policyType: HOME,
        policyStatus: ACTIVE,
        policyHolder: {
            customerId: "cust-012",
            firstName: "Kevin",
            lastName: "Okafor",
            email: "kevin.okafor@example.com",
            phoneNumber: "+1-555-1212",
            mailingAddress: {
                streetLine1: "250 Redwood Blvd",
                city: "Atlanta",
                state: "GA",
                zipCode: "30301",
                country: "US"
            }
        },
        effectiveDate: "2025-09-01",
        expirationDate: "2026-09-01",
        annualPremium: 1650.00d,
        coverages: [
            {
                coverageType: DWELLING,
                limitAmount: 320000.00d,
                deductibleAmount: 2000.00d,
                premiumAmount: 1100.00d
            },
            {
                coverageType: PERSONAL_PROPERTY,
                limitAmount: 60000.00d,
                deductibleAmount: 500.00d,
                premiumAmount: 350.00d
            },
            {
                coverageType: LIABILITY,
                limitAmount: 100000.00d,
                deductibleAmount: 0.00d,
                premiumAmount: 200.00d
            }
        ],
        insuredVehicle: (),
        insuredProperty: {
            propertyId: "prop-008",
            propertyAddress: {
                streetLine1: "250 Redwood Blvd",
                city: "Atlanta",
                state: "GA",
                zipCode: "30301",
                country: "US"
            },
            propertyType: "Single Family Home",
            estimatedValue: 380000.00d
        },
        createdAt: now,
        updatedAt: now
    };

    // Seed Quote 1 – AUTO quote (ISSUED)
    Quote autoQuote = {
        quoteId: "qte-001",
        quoteNumber: "QTE-AUTO001",
        policyType: AUTO,
        quoteStatus: ISSUED,
        applicant: {
            customerId: "cust-004",
            firstName: "David",
            lastName: "Kim",
            email: "david.kim@example.com",
            phoneNumber: "+1-555-0404",
            mailingAddress: {
                streetLine1: "321 Pine Road",
                city: "Seattle",
                state: "WA",
                zipCode: "98101",
                country: "US"
            }
        },
        riskDetails: {
            vehicle: {
                vin: "2T1BURHE0JC043821",
                make: "Toyota",
                model: "Corolla",
                year: 2021,
                licensePlate: "WA-XYZ789"
            },
            property: (),
            driverAge: 35,
            yearsWithoutClaims: 5
        },
        proposedCoverages: [
            {
                coverageType: LIABILITY,
                limitAmount: 100000.00d,
                deductibleAmount: 500.00d,
                premiumAmount: 550.00d
            },
            {
                coverageType: COLLISION,
                limitAmount: 40000.00d,
                deductibleAmount: 1000.00d,
                premiumAmount: 350.00d
            }
        ],
        estimatedAnnualPremium: 900.00d,
        estimatedMonthlyPremium: 75.00d,
        quoteValidUntil: "2026-08-01",
        boundPolicyId: (),
        createdAt: now,
        updatedAt: now
    };

    // Seed Quote 2 – HOME quote (DRAFT)
    Quote homeQuote = {
        quoteId: "qte-002",
        quoteNumber: "QTE-HOME001",
        policyType: HOME,
        quoteStatus: DRAFT,
        applicant: {
            customerId: "cust-005",
            firstName: "Emma",
            lastName: "Wilson",
            email: "emma.wilson@example.com",
            phoneNumber: "+1-555-0505",
            mailingAddress: {
                streetLine1: "654 Elm Street",
                city: "Denver",
                state: "CO",
                zipCode: "80201",
                country: "US"
            }
        },
        riskDetails: {
            vehicle: (),
            property: {
                propertyId: "prop-003",
                propertyAddress: {
                    streetLine1: "654 Elm Street",
                    city: "Denver",
                    state: "CO",
                    zipCode: "80201",
                    country: "US"
                },
                propertyType: "Townhouse",
                estimatedValue: 280000.00d
            },
            constructionType: "Wood Frame",
            buildingAge: 15
        },
        proposedCoverages: [
            {
                coverageType: DWELLING,
                limitAmount: 280000.00d,
                deductibleAmount: 1500.00d,
                premiumAmount: 1100.00d
            },
            {
                coverageType: LIABILITY,
                limitAmount: 100000.00d,
                deductibleAmount: 0.00d,
                premiumAmount: 180.00d
            }
        ],
        estimatedAnnualPremium: 1280.00d,
        estimatedMonthlyPremium: 106.67d,
        quoteValidUntil: "2026-09-01",
        boundPolicyId: (),
        createdAt: now,
        updatedAt: now
    };

    // Seed Quote 3 – COMMERCIAL quote (ISSUED)
    Quote commercialQuote = {
        quoteId: "qte-003",
        quoteNumber: "QTE-COM001",
        policyType: COMMERCIAL,
        quoteStatus: ISSUED,
        applicant: {
            customerId: "cust-013",
            firstName: "Laura",
            lastName: "Bennett",
            email: "laura.bennett@example.com",
            phoneNumber: "+1-555-1313",
            mailingAddress: {
                streetLine1: "400 Industrial Way",
                city: "Houston",
                state: "TX",
                zipCode: "77001",
                country: "US"
            }
        },
        riskDetails: {
            vehicle: (),
            property: {
                propertyId: "prop-009",
                propertyAddress: {
                    streetLine1: "400 Industrial Way",
                    city: "Houston",
                    state: "TX",
                    zipCode: "77001",
                    country: "US"
                },
                propertyType: "Manufacturing Plant",
                estimatedValue: 5000000.00d
            },
            constructionType: "Steel Frame",
            buildingAge: 8
        },
        proposedCoverages: [
            {
                coverageType: GENERAL_LIABILITY,
                limitAmount: 5000000.00d,
                deductibleAmount: 25000.00d,
                premiumAmount: 9500.00d
            },
            {
                coverageType: PERSONAL_PROPERTY,
                limitAmount: 1000000.00d,
                deductibleAmount: 10000.00d,
                premiumAmount: 3200.00d
            }
        ],
        estimatedAnnualPremium: 12700.00d,
        estimatedMonthlyPremium: 1058.33d,
        quoteValidUntil: "2026-10-01",
        boundPolicyId: (),
        createdAt: now,
        updatedAt: now
    };

    // Seed Quote 4 – RENTERS quote (ISSUED)
    Quote rentersQuote = {
        quoteId: "qte-004",
        quoteNumber: "QTE-REN001",
        policyType: RENTERS,
        quoteStatus: ISSUED,
        applicant: {
            customerId: "cust-014",
            firstName: "Marcus",
            lastName: "Hill",
            email: "marcus.hill@example.com",
            phoneNumber: "+1-555-1414",
            mailingAddress: {
                streetLine1: "9 Poplar Street",
                streetLine2: "Apt 12",
                city: "Nashville",
                state: "TN",
                zipCode: "37201",
                country: "US"
            }
        },
        riskDetails: {
            vehicle: (),
            property: {
                propertyId: "prop-010",
                propertyAddress: {
                    streetLine1: "9 Poplar Street",
                    streetLine2: "Apt 12",
                    city: "Nashville",
                    state: "TN",
                    zipCode: "37201",
                    country: "US"
                },
                propertyType: "Apartment",
                estimatedValue: 25000.00d
            }
        },
        proposedCoverages: [
            {
                coverageType: PERSONAL_PROPERTY,
                limitAmount: 25000.00d,
                deductibleAmount: 250.00d,
                premiumAmount: 200.00d
            },
            {
                coverageType: LIABILITY,
                limitAmount: 100000.00d,
                deductibleAmount: 0.00d,
                premiumAmount: 130.00d
            }
        ],
        estimatedAnnualPremium: 330.00d,
        estimatedMonthlyPremium: 27.50d,
        quoteValidUntil: "2026-11-01",
        boundPolicyId: (),
        createdAt: now,
        updatedAt: now
    };

    // Seed Quote 5 – AUTO quote (ACCEPTED)
    Quote autoAcceptedQuote = {
        quoteId: "qte-005",
        quoteNumber: "QTE-AUTO002",
        policyType: AUTO,
        quoteStatus: ACCEPTED,
        applicant: {
            customerId: "cust-015",
            firstName: "Nina",
            lastName: "Flores",
            email: "nina.flores@example.com",
            phoneNumber: "+1-555-1515",
            mailingAddress: {
                streetLine1: "600 Magnolia Blvd",
                city: "San Diego",
                state: "CA",
                zipCode: "92101",
                country: "US"
            }
        },
        riskDetails: {
            vehicle: {
                vin: "1FTFW1ET5DFC10312",
                make: "Ford",
                model: "F-150",
                year: 2022,
                licensePlate: "CA-TRK22"
            },
            property: (),
            driverAge: 42,
            yearsWithoutClaims: 8
        },
        proposedCoverages: [
            {
                coverageType: LIABILITY,
                limitAmount: 100000.00d,
                deductibleAmount: 500.00d,
                premiumAmount: 520.00d
            },
            {
                coverageType: COLLISION,
                limitAmount: 45000.00d,
                deductibleAmount: 1000.00d,
                premiumAmount: 380.00d
            },
            {
                coverageType: COMPREHENSIVE,
                limitAmount: 45000.00d,
                deductibleAmount: 500.00d,
                premiumAmount: 220.00d
            }
        ],
        estimatedAnnualPremium: 1120.00d,
        estimatedMonthlyPremium: 93.33d,
        quoteValidUntil: "2026-12-01",
        boundPolicyId: (),
        createdAt: now,
        updatedAt: now
    };

    // Seed Quote 6 – HOME quote (BOUND – linked to pol-006)
    Quote homeBoundQuote = {
        quoteId: "qte-006",
        quoteNumber: "QTE-HOME002",
        policyType: HOME,
        quoteStatus: BOUND,
        applicant: {
            customerId: "cust-008",
            firstName: "George",
            lastName: "Nguyen",
            email: "george.nguyen@example.com",
            phoneNumber: "+1-555-0808",
            mailingAddress: {
                streetLine1: "500 Cedar Drive",
                city: "Miami",
                state: "FL",
                zipCode: "33101",
                country: "US"
            }
        },
        riskDetails: {
            vehicle: (),
            property: {
                propertyId: "prop-005",
                propertyAddress: {
                    streetLine1: "500 Cedar Drive",
                    city: "Miami",
                    state: "FL",
                    zipCode: "33101",
                    country: "US"
                },
                propertyType: "Single Family Home",
                estimatedValue: 520000.00d
            },
            constructionType: "Concrete Block",
            buildingAge: 12
        },
        proposedCoverages: [
            {
                coverageType: DWELLING,
                limitAmount: 450000.00d,
                deductibleAmount: 3000.00d,
                premiumAmount: 1700.00d
            },
            {
                coverageType: PERSONAL_PROPERTY,
                limitAmount: 90000.00d,
                deductibleAmount: 1000.00d,
                premiumAmount: 500.00d
            },
            {
                coverageType: LIABILITY,
                limitAmount: 200000.00d,
                deductibleAmount: 0.00d,
                premiumAmount: 200.00d
            }
        ],
        estimatedAnnualPremium: 2400.00d,
        estimatedMonthlyPremium: 200.00d,
        quoteValidUntil: "2026-07-01",
        boundPolicyId: "pol-006",
        createdAt: now,
        updatedAt: now
    };

    // Seed Quote 7 – COMMERCIAL quote (EXPIRED)
    Quote commercialExpiredQuote = {
        quoteId: "qte-007",
        quoteNumber: "QTE-COM002",
        policyType: COMMERCIAL,
        quoteStatus: EXPIRED,
        applicant: {
            customerId: "cust-016",
            firstName: "Oscar",
            lastName: "Reyes",
            email: "oscar.reyes@example.com",
            phoneNumber: "+1-555-1616",
            mailingAddress: {
                streetLine1: "55 Harbor View",
                city: "San Francisco",
                state: "CA",
                zipCode: "94101",
                country: "US"
            }
        },
        riskDetails: {
            vehicle: (),
            property: {
                propertyId: "prop-011",
                propertyAddress: {
                    streetLine1: "55 Harbor View",
                    city: "San Francisco",
                    state: "CA",
                    zipCode: "94101",
                    country: "US"
                },
                propertyType: "Retail Store",
                estimatedValue: 800000.00d
            },
            constructionType: "Brick",
            buildingAge: 30
        },
        proposedCoverages: [
            {
                coverageType: GENERAL_LIABILITY,
                limitAmount: 1000000.00d,
                deductibleAmount: 5000.00d,
                premiumAmount: 4200.00d
            },
            {
                coverageType: PERSONAL_PROPERTY,
                limitAmount: 300000.00d,
                deductibleAmount: 2500.00d,
                premiumAmount: 1800.00d
            }
        ],
        estimatedAnnualPremium: 6000.00d,
        estimatedMonthlyPremium: 500.00d,
        quoteValidUntil: "2025-12-31",
        boundPolicyId: (),
        createdAt: now,
        updatedAt: now
    };

    // Seed Quote 8 – AUTO quote (DRAFT)
    Quote autoDraftQuote = {
        quoteId: "qte-008",
        quoteNumber: "QTE-AUTO003",
        policyType: AUTO,
        quoteStatus: DRAFT,
        applicant: {
            customerId: "cust-017",
            firstName: "Priya",
            lastName: "Sharma",
            email: "priya.sharma@example.com",
            phoneNumber: "+1-555-1717",
            mailingAddress: {
                streetLine1: "14 Juniper Road",
                city: "Minneapolis",
                state: "MN",
                zipCode: "55401",
                country: "US"
            }
        },
        riskDetails: {
            vehicle: {
                vin: "KNDJN2A27F7123456",
                make: "Kia",
                model: "Soul",
                year: 2024,
                licensePlate: "MN-KIA24"
            },
            property: (),
            driverAge: 28,
            yearsWithoutClaims: 2
        },
        proposedCoverages: [
            {
                coverageType: LIABILITY,
                limitAmount: 100000.00d,
                deductibleAmount: 500.00d,
                premiumAmount: 610.00d
            },
            {
                coverageType: COLLISION,
                limitAmount: 30000.00d,
                deductibleAmount: 1000.00d,
                premiumAmount: 420.00d
            }
        ],
        estimatedAnnualPremium: 1030.00d,
        estimatedMonthlyPremium: 85.83d,
        quoteValidUntil: "2026-12-31",
        boundPolicyId: (),
        createdAt: now,
        updatedAt: now
    };

    // Seed Quote 9 – RENTERS quote (DRAFT)
    Quote rentersDraftQuote = {
        quoteId: "qte-009",
        quoteNumber: "QTE-REN002",
        policyType: RENTERS,
        quoteStatus: DRAFT,
        applicant: {
            customerId: "cust-018",
            firstName: "Quinn",
            lastName: "Adams",
            email: "quinn.adams@example.com",
            phoneNumber: "+1-555-1818",
            mailingAddress: {
                streetLine1: "7 Chestnut Circle",
                streetLine2: "Apt 2B",
                city: "Charlotte",
                state: "NC",
                zipCode: "28201",
                country: "US"
            }
        },
        riskDetails: {
            vehicle: (),
            property: {
                propertyId: "prop-012",
                propertyAddress: {
                    streetLine1: "7 Chestnut Circle",
                    streetLine2: "Apt 2B",
                    city: "Charlotte",
                    state: "NC",
                    zipCode: "28201",
                    country: "US"
                },
                propertyType: "Apartment",
                estimatedValue: 18000.00d
            }
        },
        proposedCoverages: [
            {
                coverageType: PERSONAL_PROPERTY,
                limitAmount: 18000.00d,
                deductibleAmount: 250.00d,
                premiumAmount: 160.00d
            },
            {
                coverageType: LIABILITY,
                limitAmount: 50000.00d,
                deductibleAmount: 0.00d,
                premiumAmount: 100.00d
            }
        ],
        estimatedAnnualPremium: 260.00d,
        estimatedMonthlyPremium: 21.67d,
        quoteValidUntil: "2026-12-31",
        boundPolicyId: (),
        createdAt: now,
        updatedAt: now
    };

    // Seed Quote 10 – HOME quote (ISSUED)
    Quote homeIssuedQuote = {
        quoteId: "qte-010",
        quoteNumber: "QTE-HOME003",
        policyType: HOME,
        quoteStatus: ISSUED,
        applicant: {
            customerId: "cust-019",
            firstName: "Rachel",
            lastName: "Torres",
            email: "rachel.torres@example.com",
            phoneNumber: "+1-555-1919",
            mailingAddress: {
                streetLine1: "88 Sycamore Lane",
                city: "Columbus",
                state: "OH",
                zipCode: "43201",
                country: "US"
            }
        },
        riskDetails: {
            vehicle: (),
            property: {
                propertyId: "prop-013",
                propertyAddress: {
                    streetLine1: "88 Sycamore Lane",
                    city: "Columbus",
                    state: "OH",
                    zipCode: "43201",
                    country: "US"
                },
                propertyType: "Single Family Home",
                estimatedValue: 240000.00d
            },
            constructionType: "Wood Frame",
            buildingAge: 22
        },
        proposedCoverages: [
            {
                coverageType: DWELLING,
                limitAmount: 240000.00d,
                deductibleAmount: 1500.00d,
                premiumAmount: 950.00d
            },
            {
                coverageType: PERSONAL_PROPERTY,
                limitAmount: 50000.00d,
                deductibleAmount: 500.00d,
                premiumAmount: 280.00d
            },
            {
                coverageType: LIABILITY,
                limitAmount: 100000.00d,
                deductibleAmount: 0.00d,
                premiumAmount: 170.00d
            }
        ],
        estimatedAnnualPremium: 1400.00d,
        estimatedMonthlyPremium: 116.67d,
        quoteValidUntil: "2026-12-31",
        boundPolicyId: (),
        createdAt: now,
        updatedAt: now
    };

    lock {
        policyStore["pol-001"] = autoPolicy.clone();
        policyStore["pol-002"] = homePolicy.clone();
        policyStore["pol-003"] = commercialPolicy.clone();
        policyStore["pol-004"] = rentersPolicy.clone();
        policyStore["pol-005"] = autoExpiredPolicy.clone();
        policyStore["pol-006"] = homePolicyTwo.clone();
        policyStore["pol-007"] = commercialPolicyTwo.clone();
        policyStore["pol-008"] = autoPendingPolicy.clone();
        policyStore["pol-009"] = rentersCancelledPolicy.clone();
        policyStore["pol-010"] = homePolicyThree.clone();
    }

    lock {
        quoteStore["qte-001"] = autoQuote.clone();
        quoteStore["qte-002"] = homeQuote.clone();
        quoteStore["qte-003"] = commercialQuote.clone();
        quoteStore["qte-004"] = rentersQuote.clone();
        quoteStore["qte-005"] = autoAcceptedQuote.clone();
        quoteStore["qte-006"] = homeBoundQuote.clone();
        quoteStore["qte-007"] = commercialExpiredQuote.clone();
        quoteStore["qte-008"] = autoDraftQuote.clone();
        quoteStore["qte-009"] = rentersDraftQuote.clone();
        quoteStore["qte-010"] = homeIssuedQuote.clone();
    }
}
