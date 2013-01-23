module CoaOpScraper
  class OpinionMetadata
    attr_accessor :docket_no, :date, :author, :disposition, :metadata

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

    def metadata
      @metadata
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
