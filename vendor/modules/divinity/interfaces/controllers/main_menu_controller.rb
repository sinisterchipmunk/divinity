class MainMenuController < InterfaceController
  def button_clicked
    puts 'click!'
    redirect_to :action => :index
  end

  def index

  end
end
