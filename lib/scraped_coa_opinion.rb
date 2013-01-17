module CoaOpScraper
	class OpinionMetadata
		attr_accessor :docket_no, :date, :author, :disposition

		def initialize(scraped_metadata)
			dno = CoaOpScraper::CoaDocketNo.new(scraped_metadata[:docket_no])
			@docket_no = dno.canonical
			@date = scraped_metadata[:opinion_date]
			@author = scraped_metadata[:author_string]
			@disposition = scraped_metadata[:disposition]
			@metadata = scraped_metadata
		end

		def author
			@author
		end
	
		def disposition
			@disposition
		end
	
		def date
			@date
		end
	
		def docket_no
			@docket_no
		end
	
		def process!(&meth)
			meth.send(self)
		end

	protected

		def is_a_new_opinion?
			@docket.opinions.where(:date => @date).where(:scraped_author => @author).first.nil?
		end

		def associated_docket_object
			@dno = CoaOpScraper::CoaDocketNo.new(@docket_no)
			if @docket = CoaOpScraper::CoaDocket.dno(@dno)
				@docket
			else
				@docket = CoaDocket.insert(@dno)
			end
		end
	
		def associated_decision_object
			if @decision = @docket.decisions.where(:date => @date).first
				@decision
			else
				@decision = @docket.decisions.insert({ :date => @date, :disposition => @disposition })
			end
		end

		def insert_opinion_into_database!
			@docket.soft_insert_docket_page_url(@metadata["docket_page_url"])
			@docket.soft_insert_case_style(@metadata["case_style"])
			@docket.soft_insert_origin(@metadata["origin"])
			@decision.soft_insert_diposition(@metadata["disposition"])

			op = @docket.decisions.where(:decision_id => @decision.id).opinions.new
			op.scraped_disposition = @disposition		
			op.date = @date
			op.author_string = @metadata["author_string"]
			op.panel_string = @metadata["panel_string"]
			op.scraped_case_style = @metadata["case_style"]
			op.scraped_origin = @metadata["origin"]
			op.scraped_urls = @metadata["opinion_urls"]
			op.commit_insert
		end
		# Note: without a guard, this is destructive of previously scraped data
	
		# Opinion(id: integer, docket_id: integer, decision_id: integer, scraped_case_style: string, scraped_disposition: string, scraped_origin: string, scraped_author: string, scraped_panel: string, scraped_urls: string, author: string, panel: string, date: date, disposition: string, court_url: string, court_url_format: string, texapp_url: string, per_curiam: boolean, memorandum: boolean, not_for_publication: boolean, published: boolean, precedential: boolean, withdrawn: boolean, created_at: datetime, updated_at: datetime) 
	
			# expects a hash in this format:
			#	docket_no : 
			# docket_page_url:
			# opinion_urls: { html : url, pdf : url, wpd : url, ... }
			# case_style:
			# origin:
			# author_string:
			# panel_string:
			# disposition:
			# opinion_date:
	end
end
