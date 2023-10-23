library(shiny)
library(shinyBS)
library(ggplot2)
library(dplyr)
library(DT)
library(readxl)
library(RSiteCatalyst)
library(DataCache)

##readRenviron(paste0(getwd(),"/.Renviron"))

rsid = Sys.getenv('AW_REPORTSUITE_ID')
appCache = cache.info(cache.dir="cache", cache.name=rsid)

# LOAD DATA ####
getConfiguration = function(rsid){
	SCAuth(Sys.getenv('AW_USERNAME'), Sys.getenv('AW_SECRET'), debug.mode = FALSE)

	# GET REPORT SUITES #### #####################################################
	reportSuites = GetReportSuites()

	# GET PROPS #### #############################################################
	props = GetProps(rsid)
	props = subset(props, select = -c(enabled, participation_enabled, case_insensitive, case_insensitive_date_enabled, report_suite)) # delete some cols
	props = props[, c("id", "name", "pathing_enabled", "list_enabled", "list_delimiter", "description") ] # change col order
	colnames(props) = c("Prop", "Label", "Pathing", "List Support", "Delimiter", "Description")

	# GET EVARS #### #############################################################
	evars = GetEvars(rsid)
	evars = subset(evars, select = -c(enabled, has_custom_name_matching_default, expiration_custom_days, report_suite)) # delete some cols
	evars = evars[, c("id","name", "type", "expiration_type", "allocation_type", "description") ] # change col order
	colnames(evars) = c("eVar","Label","Type","Expiration","Allocation","Description")

	# GET EVENTS #### ############################################################
	events = GetSuccessEvents(rsid)
	events = subset(events, select = -c(default_metric, participation, polarity, visibility, report_suite, site_title,ecommerce_level)) # delete some cols
	events = events[, c("id","name","type", "serialization", "description") ] # change col order
	colnames(events) = c("Event","Label","Type","Serialisation", "Description")

	# GET PROCESSING RULES #### ##################################################
	procRules = ViewProcessingRules(rsid)
	procRules = subset(procRules, select = -c(rsid, editable)) # delete some cols
	procRules = procRules[, c("ruleNum","title","rules", "matchOn", "actions", "comment") ] # change col order
	colnames(procRules) = c("Rule","Section","Conditions","Match Type","Actions","Comments")

	# GET LIST VARS #### ##################################################$$$$$$$
	listvars = GetListVariables(rsid)
	listvars = subset(listvars, select = -c(rsid, site_title)) # delete some cols
	listvars = listvars[, c("name","allocation_type","enabled", "value_delimiter", "max_values", "id", "expiration_custom_days", "expiration_type", "description") ] # change col order
	colnames(listvars) = c("ListVar","Allocation","Enabled","Delimiter","Max","ID", "Expiry Days", "Expiry Type", "Description")

	# GET MARKETING CHANNELS #### ##################################################$$$$$$$
	mktChannels = GetMarketingChannels(rsid)
	mktChannels = subset(mktChannels, select = -c(rsid, type, color, channel_breakdown)) # delete some cols
	colnames(mktChannels) = c("Marketing Channel Name","Channel ID","Enabled","Override Last Touch Channel")

	# GET MARKETING CHANNELS #### ##################################################$$$$$$$
	mktProcRules = GetMarketingChannelRules(rsid)
	mktProcRules = subset(mktProcRules, select = -c(rsid)) # delete some cols
	colnames(mktProcRules) = c("Ruleset", "Channel ID", "Junction", "Type", "ID", "Query String", "Rule ID", "Hit Attribute", "Hit Query Param", "Operator", "Matches")

	results = list(
		"props" =       props,
		"evars" =       evars,
		 # "metrics" =  GetMetrics(rsid),
		"events" =      events,
		"listvars" =    listvars,
		"procRules" =   procRules,
		"mktChannels" = mktChannels,
		"mktProcRules"= mktProcRules,
		"reportSuites"= reportSuites
	)

	return(results)
}

tableOptions = list(
	pageLength = -1,
	paging = FALSE,
	orderClasses = TRUE,
	dom = 'Bfr',
	buttons = list("copy", list(extend = "collection",
		buttons = c("csv", "excel", "pdf"), text = "Download")
	),
	searchHighlight = TRUE
)

## Uncomment during dev, and to force cache refresh
#unlink('cache', recursive=TRUE, force=TRUE)
data.cache(getConfiguration, cache.name=rsid, rsid=rsid, frequency = "hourly")

function(input, output) {

	# [PROPS] - Traffic Variables ####
	output$propsTBL <- renderDataTable(
		datatable(
			data = props,
			options = tableOptions,
			rownames = FALSE,
			extensions = c('Buttons', 'ColReorder')
		)
	)

	# [EVARS] - Conversion Variables ####
	output$evarsTBL <- renderDataTable(
		datatable(
			data = evars,
			options = tableOptions,
			rownames = FALSE
		)
	)

	# [SUCCESS EVENTS] - Success Events ####
	output$eventsTBL <- renderDataTable(
		datatable(
			data = events,
			options = tableOptions,
			rownames = FALSE
		)
	)

	# [LISTVARS] - List Vars ####
	output$listvarsTBL <- renderDataTable(
		datatable(
			data = listvars,
			options = tableOptions,
			rownames = FALSE
		)
	)

	# [PROCESSING RULES] Processing Rules ####
	output$procRulesTBL <- renderDataTable(
		datatable(
			data = procRules,
			options = tableOptions,
			rownames = FALSE
		)
		%>% formatStyle(c('Actions','Conditions'), fontFamily = 'monospace')
	)

	# [MARKETING CHANNELS]
	output$mktChannelsTBL <- renderDataTable(
		datatable(
			data = mktChannels,
			options = tableOptions,
			rownames = FALSE
		)
	)

	# [MARKETING CHANNELS PROCESSING RULES]
	output$mktProcRulesTBL <- renderDataTable(
		datatable(
			data = mktProcRules,
			options = tableOptions,
			rownames = FALSE
		)
		%>% formatStyle(c('Query String','Hit Attribute','Hit Query Param','Matches'), fontFamily = 'monospace')
	)

	# [REPORT SUITES]
	output$reportSuitesTBL <- renderDataTable(
		datatable(
			data = reportSuites,
			options = tableOptions,
			rownames = FALSE
		)
	)

	# [CACHE]
	output$cacheTBL <- renderDataTable(
		datatable(
			data = appCache,
			options = tableOptions,
			rownames = FALSE
		)
	)
}