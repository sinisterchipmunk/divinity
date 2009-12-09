class MainMenuController < InterfaceController
  def button_clicked
    puts "#{event.model.inspect} says: click!"
    if event.model.action == 'single_player'
      redirect_to :controller => 'gameplay'
    else
      redirect_to :action => :index
    end
  end

  def index

  end
end
