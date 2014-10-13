require 'rails_helper'

def execute_sql(action)
  action.execute.gsub(/\"/, '').gsub(/`/, '')
end

module AllYourMigrations
  describe Action do

    context 'insert' do
      describe '#execute' do
        before :example do
          @action = Action.new(model: Merchant, type: :insert)
          @action.values(:legacy_id, :name)
          @action.from(Legacy::Vendor.all.select(:vendor_id, :name))
        end
        it 'returns the correct SQL' do
          expect(execute_sql(@action)).to eq('INSERT INTO merchants (legacy_id,name) SELECT perx_legacy.vendor.vendor_id, perx_legacy.vendor.name FROM perx_legacy.vendor')
        end
        it 'executes the correct SQL' do
          expect{ @action.execute! }.to change{Merchant.count}.by(Legacy::Vendor.count)
        end
      end
    end

    context 'update' do
      describe '#execute' do
        before :example do
          @action = Action.new(model: Merchant, type: :update)
          @action.from(Merchant.joins(:legacy)
                               .where(vendor: {active: true})
                               .select(:name))
        end

        it 'returns the correct SQL' do
          @action.set('merchants.name = perx_legacy.vendor.name')
          expect(execute_sql(@action)).to eq('UPDATE merchants INNER JOIN perx_legacy.vendor ON perx_legacy.vendor.vendor_id = merchants.legacy_id SET merchants.name = perx_legacy.vendor.name WHERE perx_legacy.vendor.active = 1')
        end

        it 'executes the correct SQL' do
          action = Action.new(model: Merchant, type: :truncate)
          action.execute!
          expect(Merchant.count).to eq 0
          action = Action.new(model: Merchant, type: :insert)
          action.values(:legacy_id, :name)
          action.from(Legacy::Vendor.all.select(:vendor_id, :name))
          action.execute!

          expect(Merchant.count).to eq 902
          @action.set("merchants.name = 'FRED'")
          @action.execute!
          expect(Merchant.where(name: 'FRED').first.name).to eq 'FRED'
        end
      end
    end

    context 'truncate' do
      describe '#execute' do
        it 'returns the correct SQL' do
          action = Action.new(model: Merchant, type: :truncate)
          expect(action.execute).to eq 'TRUNCATE TABLE merchants'
        end
        it 'removes all records from the table' do
          action = Action.new(model: Merchant, type: :truncate)
          action.execute!
          expect(Merchant.count).to eq 0
          action = Action.new(model: Merchant, type: :insert)
          action.values(:legacy_id, :name)
          action.from(Legacy::Vendor.all.select(:vendor_id, :name))
          action.execute!
          expect(Merchant.count).to eq 902
          action = Action.new(model: Merchant, type: :truncate)
          action.execute!
          expect(Merchant.count).to eq 0
        end
      end
    end

  end
end

