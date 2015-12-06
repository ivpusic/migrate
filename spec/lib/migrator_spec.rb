describe "Migrator" do
  $dbs.each do |db|
    config = db.config
    migrator = Migrator.new(config)

    around(:each) do |test|
      db.tx do
        test.run
      end
    end

    context db.type do
      it "should be able to initialize" do
        expect{Migrator.new(config)}.not_to raise_error(Exception)
      end

      it "should make new migration" do
        migration_dir = nil

        begin
          result = db.exec_sql("SELECT * FROM #{config.version_info} ORDER BY version DESC")
          version = db.extract_version result

          migration_dir = migrator.new("description")

          result = db.exec_sql("SELECT * FROM #{config.version_info} ORDER BY version DESC")
          new_version = db.extract_version result
          expect(new_version.to_i).to eq(version.to_i + 1)
          expect(Dir.exist? migration_dir).to be true
        ensure
          if migration_dir != nil
            Dir.glob("#{migration_dir}/{up.*,down.*}").each do |file|
              File.delete file
            end

            Dir.rmdir migration_dir
          end
        end
      end

      create_migration_dir = lambda do |version|
        migration = db.get_migration(version)
        migration_dir = migrator.migration_dir(migration)

        if not Dir.exist? migration_dir
          Dir.mkdir migration_dir
          config.get_lang().create_migration(migration_dir)
        end
      end

      it "should execute one up migration" do
        current = db.current_version().to_i
        create_migration_dir.call(current + 1)
        migrator.up

        expect(current.to_i + 1).to eq(db.current_version().to_i)
      end

      it "should execute multiple up migration" do
        current = db.current_version().to_i
        create_migration_dir.call(current + 1)
        create_migration_dir.call(current + 2)

        migrator.up(current + 2)
        expect(current.to_i + 2).to eq(db.current_version().to_i)
      end

      it "should execute one down migration" do
        current = db.current_version().to_i
        create_migration_dir.call(current)

        migrator.down
        expect(current.to_i - 1).to eq(db.current_version().to_i)
      end

      it "should execute multiple up migration" do
        current = db.current_version().to_i
        create_migration_dir.call(current)
        create_migration_dir.call(current - 1)

        migrator.down(current - 2)
        expect(current.to_i - 2).to eq(db.current_version().to_i)
      end

      it "should get current version" do
        current = db.current_version().to_i
        expect(migrator.current_version().to_i).to eq(current)
      end

      it "should delete one version" do
        delete = db.current_version().to_i + 1
        migrator.delete(delete)
        expect{db.get_migration(delete)}.to raise_error(VersionNotFound)
      end

      it "should not delete current version" do
        current = db.current_version().to_i
        migrator.delete(current)
        expect(db.get_migration(current)["version"].to_i).to eq(current)
      end
    end
  end
end
