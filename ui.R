library(DataCache)
rsid = Sys.getenv('AW_REPORTSUITE_ID')
appCache = cache.info(cache.dir="cache", cache.name=rsid)
appCacheCreated = appCache[1, "created"]
#appCacheAgeMins = 0
appCacheAgeMins = 1
#appCacheAgeMins = round(appCache[1, "age_mins"])
# set a default value for appCacheAgeMins

navbarPage(
	title = Sys.getenv('APP_TITLE'),

	tabPanel("Props",              DT::dataTableOutput("propsTBL")       ),
	tabPanel("eVars",              DT::dataTableOutput("evarsTBL")       ),
	tabPanel("Events",             DT::dataTableOutput("eventsTBL")      ),
	tabPanel("ListVars",           DT::dataTableOutput("listvarsTBL")    ),
	tabPanel("Proc Rules",         DT::dataTableOutput("procRulesTBL")   ),
	tabPanel("Marketing Channels", DT::dataTableOutput("mktChannelsTBL") ),
	tabPanel("Channel Rules",      DT::dataTableOutput("mktProcRulesTBL")),
	navbarMenu("More",
		tabPanel("Data Preview",   DT::dataTableOutput("dataPreviewTBL") ),
		tabPanel("Report Suites",  DT::dataTableOutput("reportSuitesTBL")),
		tabPanel("Cache",          DT::dataTableOutput("cacheTBL")       ),
	),
	footer = HTML(paste0("
	<footer style=\"border-top:1px solid #ddd;padding:10px 0px;margin:15px 15px;font-size:11px;color: #888;\">",
	"Report Suite: ", "<code>", rsid, "</code>",
	" Cached: ", "<code>", appCacheCreated, "</code>",
	" Age: ", "<code>", appCacheAgeMins, " minutes</code>","</footer>"))
)
