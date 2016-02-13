describe "Storage" do
  $dbs.each do |db|
    around(:each) do |test|
      db.tx do
        test.run
      end
    end

    context db.type do
      it "should create new migration" do
        created = db.new_migration(200, "this is description")
        expect(created["version"].to_i).to eq(200)
        expect(created).not_to eq(nil)
        expect(db.exec_sql(
          "SELECT * FROM #{$version_info} WHERE version=#{created["version"]}")[0])
          .to eq(created)
      end

      it "should list all migrations" do
        migrations = db.list_migrations(nil, nil)
        expect(migrations.count).to eq(5)
        expect(migrations[0].keys).to eq(["version", "description", "created_date", "last_up", "last_down"])
      end

      it "should filter list of migrations" do
        select = "version,created_date"
        limit = 2

        migrations = db.list_migrations(select, limit)
        expect(migrations.count).to eq(limit)
        expect(migrations[0].keys).to eq(["version", "created_date"])
      end

      describe "should get all migrations in range" do
        context "when doing up" do
          it do
            migrations = db.migrations_range(2, 4, true)
            expect(migrations.count).to eq(3)
            expect(migrations[0]["version"].to_s).to eq("2")
            expect(migrations[1]["version"].to_s).to eq("3")
            expect(migrations[2]["version"].to_s).to eq("4")
          end
        end

        context "when doing down" do
          it do
            migrations = db.migrations_range(2, 4, false)
            expect(migrations.count).to eq(3)
            expect(migrations[0]["version"].to_s).to eq("4")
            expect(migrations[1]["version"].to_s).to eq("3")
            expect(migrations[2]["version"].to_s).to eq("2")
          end
        end
      end

      it "should be able to check if version table already exists" do
        exists = db.tables_exists?
        expect(exists).to be true
      end

      it "should get lowest version" do
        version = db.lowest_version
        expect(version.to_s).to eq("1")
      end

      it "should get next version" do
        nxt = db.next_version
        expect(nxt.to_s).to eq("4")
      end

      it "should get current version" do
        current = db.current_version
        expect(current.to_s).to eq("3")
      end

      it "should get previous version" do
        prev = db.prev_version
        expect(prev.to_s).to eq("2")
      end

      it "should perform log up" do
        db.log_up(4)
        current = db.current_version
        expect(current.to_s).to eq("4")
      end

      it "should perform log down" do
        db.log_down("1")
        current = db.current_version
        expect(current.to_s).to eq("0")
      end

      it "should get migration" do
        migration = db.get_migration(4)
        expect(migration["version"].to_s).to eq("4")
      end

      it "should delete migration" do
        db.delete(4)
        expect{db.get_migration(4)}.to raise_error(VersionNotFound)
      end

      it "should exec sql" do
        result = db.exec_sql("SELECT * FROM #{$version_info}")
        expect(result.count).to eq(5)
      end
    end
  end
end
