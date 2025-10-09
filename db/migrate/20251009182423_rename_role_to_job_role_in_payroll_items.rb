class RenameRoleToJobRoleInPayrollItems < ActiveRecord::Migration[8.0]
  def change
    # Si usas strong_migrations y el lintern te advierte, puedes envolver con:
    # safety_assured { rename_column :payroll_items, :role, :job_role }
    rename_column :payroll_items, :role, :job_role
  end
end
