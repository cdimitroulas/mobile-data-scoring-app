status_ary = ["Application Pending", "Application Accepted", "Loan Outstanding", "Application Declined", "Loan Repaid"]
category_ary = ["Personal", "Business"]
purpose_ary = ["Medical Expenses", "Start a business", "Open a shop", "Buy equipment for my business"]
description_ary = ["I need to pay for a organ transplant for my son",
               "I want to buy a large amount of cooking utensils for my kitchen as the restaurant is expanding",
               "I would like to open a clothes shop as there are none in this area",
               "I want to start my own tech business and I need the money to launch my product"]
start_date_outstanding_ary = [(DateTime.now - 3.day), (DateTime.now - 1.month), (DateTime.now - 2.month), (DateTime.now - 3.month), (DateTime.now - 7.day)]
start_date_repaid_ary = [(DateTime.now - 1.month), (DateTime.now - 2.month), (DateTime.now - 3.month), (DateTime.now - 20.day), (DateTime.now -3.day)]

bank = Bank.last
50.times do
  user = User.create!(mobile_number: Faker::PhoneNumber.cell_phone, password: 'testtest', first_name: Faker::Name.first_name, last_name: Faker::Name.last_name)
  loan = user.loans.build(status: status_ary.sample, category: category_ary.sample, purpose: purpose_ary.sample,
                   description: description_ary.sample, interest_rate: 15, bank: bank,
                   requested_amount_cents: rand(1500000).round(-3))
  loan.proposed_amount_cents = loan.requested_amount_cents
  loan.agreed_amount_cents = loan.requested_amount_cents

  case loan.status
  when "Loan Outstanding"
    loan.start_date = start_date_outstanding_ary.sample
    loan.final_date = loan.start_date + loan.duration_months.month
    loan.most_recent_payment.paid = true if loan.most_recent_payment
    loan.most_recent_payment.save
    loan.update_payments_to_agreed_amount
  when "Loan Repaid"
    loan.start_date = start_date_repaid_ary.sample
    loan.final_date = loan.start_date + loan.duration_months.month
    loan.update_payments_to_agreed_amount
    loan.payments.each do |payment|
      payment.paid = true
      payment.save!
    end
  when "Application Accepted"
    loan.create_payments_proposed
  when "Application Declined"
    loan.start_date = start_date_outstanding_ary.sample
    loan.final_date = loan.start_date + 3.day
  end
  loan.save!
end
