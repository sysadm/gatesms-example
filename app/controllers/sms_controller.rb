# encoding: utf-8
require "digest"

class SmsController < ApplicationController
  layout false, :only => :update_status
  protect_from_forgery :except => :update_status

  def update_status
    @sms = Sms.find_by_localid(params[:LocalId].to_i)
    if @sms and @sms.globalid == params[:Id].to_i
      update = @sms.update_attributes(:status_id=>params[:Status].to_i)
    end
    #for header in request.env.select {|k,v| k.match("^X.*") }
    #  p header.inspect
    #end
    if update
      render :text => "ok", :status => 204
    else
      render :text => "continue", :status => 202
    end
  end

  # GET /sms
  # GET /sms.json
  def index
    @sms = Sms.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @sms }
    end
  end

  # GET /sms/1
  # GET /sms/1.json
  def show
    @sms = Sms.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @sms }
    end
  end

  # GET /sms/new
  # GET /sms/new.json
  def new
    @sms = Sms.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @sms }
    end
  end

  # GET /sms/1/edit
  def edit
    @sms = Sms.find(params[:id])
  end

  # POST /sms
  # POST /sms.json
  def create
    @sms = Sms.new(params[:sms])

    respond_to do |format|
      if @sms.save
        format.html { redirect_to @sms, notice: 'Sms was successfully created.' }
        format.json { render json: @sms, status: :created, location: @sms }
      else
        format.html { render action: "new" }
        format.json { render json: @sms.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /sms/1
  # PUT /sms/1.json
  def update
    @sms = Sms.find(params[:id])

    respond_to do |format|
      if @sms.update_attributes(params[:sms])
        format.html { redirect_to @sms, notice: 'Sms was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @sms.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sms/1
  # DELETE /sms/1.json
  def destroy
    @sms = Sms.find(params[:id])
    @sms.destroy

    respond_to do |format|
      format.html { redirect_to sms_index_url }
      format.json { head :no_content }
    end
  end

  def send_message
    @sms = Sms.find(params[:id])
    @sms.send_message
    render :show
  end

  def request_status
    @sms = Sms.find(params[:id])
    @sms.send_message
    render :show
  end
end
