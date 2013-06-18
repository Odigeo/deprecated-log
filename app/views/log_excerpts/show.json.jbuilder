json.log_excerpt do |json|
	json._links       hyperlinks(self: url_for(from: @from, to: @to))
	json.from         @from
	json.to           @to
	json.entries      @entries
end
