import pandas as pd
import random
from faker import Faker
from datetime import datetime, timedelta

fake = Faker()
Faker.seed(42)
random.seed(42)

NUM_POLICIES = 1000
NUM_CLAIMS = 1200

# 1. GENERATE POLICYCENTER DATA
policy_types = ['Personal Auto', 'Commercial Property', 'General Liability', 'Homeowners']
policies = []

for i in range(1, NUM_POLICIES + 1):
    policy_id = f"POL-{10000 + i}"
    policy_type = random.choice(policy_types)
    eff_date = fake.date_between(start_date='-2y', end_date='-1y')
    exp_date = eff_date + timedelta(days=365)
    written_premium = round(random.uniform(800, 5000), 2)
    earned_premium = round(written_premium * random.uniform(0.75, 1.0), 2)
    
    policies.append({
        "policy_id": policy_id,
        "policy_number": f"PC-{random.randint(100000, 999999)}",
        "policy_type": policy_type,
        "effective_date": eff_date,
        "expiration_date": exp_date,
        "written_premium": written_premium,
        "earned_premium": earned_premium,
        "policy_status": "Bound"
    })

df_policies = pd.DataFrame(policies)

# 2. GENERATE CLAIMCENTER DATA
claims = []
claim_statuses = ['Closed', 'Open', 'Under Investigation']

for i in range(1, NUM_CLAIMS + 1):
    claim_id = f"CLM-{50000 + i}"
    matched_policy = random.choice(policies)
    
    loss_date = fake.date_between(start_date=matched_policy['effective_date'], end_date=matched_policy['expiration_date'])
    reported_date = loss_date + timedelta(days=random.randint(0, 15))
    
    status = random.choice(claim_statuses)
    close_date = (reported_date + timedelta(days=random.randint(5, 90))) if status == 'Closed' else None
    
    claims.append({
        "claim_id": claim_id,
        "claim_number": f"CC-{random.randint(100000, 999999)}",
        "policy_id": matched_policy['policy_id'],
        "claim_type": matched_policy['policy_type'],
        "loss_date": loss_date,
        "reported_date": reported_date,
        "close_date": close_date,
        "claim_status": status
    })

df_claims = pd.DataFrame(claims)

# 3. GENERATE CLAIM TRANSACTIONS
transactions = []
trans_id_counter = 100000

for claim in claims:
    num_tx = random.randint(1, 3)
    for _ in range(num_tx):
        trans_type = random.choice(['Loss Payment', 'Expense Payment', 'Reserve Increase'])
        amount = round(random.uniform(200, 15000), 2) if trans_type != 'Expense Payment' else round(random.uniform(50, 800), 2)
        
        transactions.append({
            "transaction_id": f"TX-{trans_id_counter}",
            "claim_id": claim['claim_id'],
            "transaction_type": trans_type,
            "amount": amount,
            "transaction_date": claim['reported_date'] + timedelta(days=random.randint(1, 20))
        })
        trans_id_counter += 1

df_transactions = pd.DataFrame(transactions)

# Export to CSV
df_policies.to_csv("pc_policy.csv", index=False)
df_claims.to_csv("cc_claim.csv", index=False)
df_transactions.to_csv("cc_transaction.csv", index=False)

print("Guidewire synthetic datasets generated successfully!")
