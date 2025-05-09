# frozen_string_literal: true

class EquityAllocation < ApplicationRecord
  belongs_to :company_worker, foreign_key: :company_contractor_id

  validates :equity_percentage, allow_nil: true,
                                numericality: {
                                  only_integer: true,
                                  greater_than_or_equal_to: 0,
                                  less_than_or_equal_to: CompanyWorker::MAX_EQUITY_PERCENTAGE,
                                }
  validates :year, presence: true,
                   numericality: { greater_than_or_equal_to: 2020, less_than_or_equal_to: 3000, only_integer: true },
                   uniqueness: { scope: :company_contractor_id }
  validate :equity_percentage_cannot_be_unset
  validate :locked_equity_percentage_cannot_change, on: :update
  validate :equity_percentage_must_be_set_if_locked

  private
    def equity_percentage_cannot_be_unset
      errors.add(:equity_percentage, "cannot be unset once set") if equity_percentage_changed? && equity_percentage.nil?
    end

    def locked_equity_percentage_cannot_change
      errors.add(:equity_percentage, "cannot be changed once locked") if equity_percentage_changed? && locked?
    end

    def equity_percentage_must_be_set_if_locked
      errors.add(:base, "Cannot lock equity percentage without setting a value") if locked_changed? && locked? && equity_percentage.nil?
    end
end
