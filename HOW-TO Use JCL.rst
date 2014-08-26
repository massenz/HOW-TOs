@Autowired
JarClassLoader jarClassLoader;
JclObjectFactory factory = JclObjectFactory.getInstance();

@Autowired
Context pluginsContext;


// TODO: obviously this would be POSTed as a file upload
jarClassLoader.add("/tmp/jcl-test.jar");

//Create object of loaded class
Object obj = factory.create(jarClassLoader, fqn);
AlertPlugin plugin = JclUtils.cast(obj, AlertPlugin.class);

logger.info("Loaded valid AlertPlugin: " + plugin.getName() + " :: " + plugin.getDescription());
plugin.startup(pluginsContext);

Pager pager = JclUtils.cast(plugin.activate(), Pager.class);

logger.info("Plugin activated, obtained Pager: " + pager.getClass().getName());

Server fakeServer = new Server(new ServerAddress("test", "10.10.121.100"), 80, 30);
fakeServer.setDescription("This is a fake server");
pager.page(fakeServer);
return "Loaded valid AlertPlugin: " + plugin.getName() + " :: " + plugin.getDescription();
