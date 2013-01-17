module CoaOpScraper
	class CoaDocketNo
	attr_accessor :no
		# Encapsulating the logic of working with COA docket numbers.
		# Note: Distinct from knowing if a valid docket number was actually used
  
  def initialize(no)
		parts = no.split("-")
		if parts.count == 4 and (parts.last == "CR" or parts.last == "CV")
    	@no = no
    else
    	@no = nil
    end
	end

	def valid?
		!@no.nil?
	end

  def to_s
    self.fixed_length
  end

  def fixed_length
  	if self.valid?
			(coa,year,number,type_suffix) = @no.split("-")
			[padded(coa,2), padded(year,2), padded(number,5), type_suffix].join('-')
		else
			""
		end
  end

	def without_type
		self.fixed_length.sub("-CR","").sub("-CV","")
	end

	#####################################
	# For accessing pieces

	def coa_number
		self.canonical.split("-")[0]
	end
	
  def year_number
    self.canonical.split("-")[1]
  end

  def case_number
    self.canonical.split("-")[2]
  end
  
	def civil?
		self.canonical.split("-")[3] == "CV"
  end
  
  def criminal?
  	self.canonical.split("-")[3] == "CR"
  end

	###################################
	# Standardizing how used internally
	
  def for_database_key
    self.without_type
  end
	# because the -CV/-CR suffix is not relevant to uniqueness

  def for_web_urls
    self.fixed_length
  end

  def canonical
    self.fixed_length
  end

protected
  def padded(number,digits)
		sprintf("%0#{digits}d", number)
	end
end
end
