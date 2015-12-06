describe "Lang" do
  langs = [
    Lang::Go.new,
    Lang::Javascript.new,
    Lang::Ruby.new,
    Lang::Sql.new($dbs[0]),
    Lang::Python.new
  ]

  langs.each do |lang|
    dir = "spec/lib/fixtures/v01"

    after(:each) do
      if Dir.exist? dir
        Dir.glob("#{dir}/{up.*,down.*}").each do |file|
          File.delete(file)
        end
        Dir.rmdir dir
      end
    end

    it "#{lang.ext} should be able to create new migration" do
      Dir.mkdir dir
      lang.create_migration(dir)

      up = "#{dir}/up.#{lang.ext}"
      down = "#{dir}/down.#{lang.ext}"

      expect(File.exist? up).to be true
      expect(File.exist? down).to be true
    end

    context "#{lang.ext} when migrating up" do
      [true, false].each do |is_up|
        it "should be able to execute migration script" do
          lang_dir = "spec/lib/fixtures/#{lang.ext}"

          if lang.ext != "sql"
            out = lang.exec_migration(lang_dir, is_up)
            expect(out.strip).to eq("works")
          end
        end
      end
    end
  end
end
