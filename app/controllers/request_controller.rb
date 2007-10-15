# app/controllers/request_controller.rb:
# Show information about one particular request.
#
# Copyright (c) 2007 UK Citizens Online Democracy. All rights reserved.
# Email: francis@mysociety.org; WWW: http://www.mysociety.org/
#
# $Id: request_controller.rb,v 1.3 2007-10-15 22:26:37 louise Exp $

class RequestController < ApplicationController
    
    def show
        @info_request = InfoRequest.find(params[:id])
    end

    def list
        @info_request_pages, @info_requests = paginate :info_requests, :per_page => 25, :order => "created_at desc"
    end
    
    def frontpage
    end

    def create
        # Create both FOI request and the first request message
        @info_request = InfoRequest.new(params[:info_request])
        @outgoing_message = OutgoingMessage.new(params[:outgoing_message].merge({ 
            :status => 'ready', 
            :message_type => 'initial_request'
        }))
        @info_request.outgoing_messages << @outgoing_message
        @outgoing_message.info_request = @info_request

        # This automatically saves dependent objects, such as @info_request, in the same transaction
        if not @info_request.valid?
            render :action => 'new'
        elsif authenticated?
            @info_request.user = authenticated_user
            @info_request.save
            flash[:notice] = "Your Freedom of Information request has been created."
            redirect_to :controller => 'request', :action => "show", :id => @info_request
        end

        # Save both models
#        valid = @info_request.valid? 
#        valid &&= @outgoing_message.valid? # XXX maybe there is a nicer way of preventing lazy boolean evaluation than this
#        if valid
#            if authenticated?
#                @info_request.save!
#                @outgoing_message.save!
#            end
#        else
#            render :action => 'index'
#        end
    end

    private

end
