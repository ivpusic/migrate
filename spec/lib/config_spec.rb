describe "Conf" do
  let!(:fixtures) { "spec/lib/fixtures"  }
  let!(:config) { Conf.new(fixtures, "example.config") }
  let!(:config_hash) {
    {
      host: "localhost",
      port: ("5432").to_i,
      database: "mydb",
      user: "postgres",
      password: "password",
      version_info: "version_info",
      version_number: "version_number"
    }
  }

  it "should create new instance" do
    expect(config).not_to eq(nil)
  end

  it "should save root" do
    expect(config.root).to eq("spec/lib/fixtures")
  end

  it "should not find file" do
    config = Conf.new(".", "custom_file.conf")
    expect(config.exists?).to eq(false)
  end

  it "should create config file" do
    config_path = "#{fixtures}/test.config"
    begin
      expect(File.exist? config_path).to be false

      config = Conf.new(fixtures, "test.config")
      config.init(config_hash)
      expect(config.exists?).to eq(true)     
      expect(File.exist? config_path). to be true
    ensure
      if File.exist? config_path
        File.delete config_path
      end
    end
  end
  
  it "should load configuration" do
    config.init(config_hash)
    config.load!
    expect(config.host).to eq("localhost")
    expect(config.port).to eq("5432")
    expect(config.database).to eq("mydb")
    expect(config.user).to eq("postgres")
    expect(config.password).to eq("password")
    expect(config.version_info).to eq("version_info")
    expect(config.version_number).to eq("version_number")
  end

  it "should remove configuration" do
    config_path = "#{fixtures}/test.config"
    begin
      expect(File.exist? config_path).to be false

      config = Conf.new(fixtures, "test.config")
      config.init(config_hash)
      expect(File.exist? config_path).to be true
      config.delete
      expect(File.exist? config_path).to be false
    ensure
      if File.exist? config_path
        File.delete config_path
      end
    end
  end

  [{type: "pg", cls: Storage::Postgres, conf: $pg_config_hash}, 
   {type: "mysql", cls: Storage::Mysql, conf: $mysql_config_hash}].each do |storage|
    context storage[:type] do
      it "should be able to get database instance" do
        config.init(storage[:conf])
        config.load!
        expect(config.get_db).to be_kind_of(storage[:cls])
      end
    end
  end

  [{type: "go", cls: Lang::Go}, {type: "sql", cls: Lang::Sql},
   {type: "ruby", cls: Lang::Ruby}, {type: "javascript", cls: Lang::Javascript}, 
   {type: "python", cls: Lang::Python}].each do |lang|
    context lang[:type] do
      it "should be able to get language instance" do
        config_hash = $pg_config_hash.merge({
          lang: lang[:type]
        })

        config.init(config_hash)
        config.load!
        expect(config.get_lang).to be_kind_of(lang[:cls])
      end
    end
  end
end
