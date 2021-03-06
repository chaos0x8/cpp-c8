#include "c8-gtkmm/MessageDialog.hpp"

namespace C8::Gtkmm {
  Gtk::ResponseType messageDialog(
    const std::string& message, const std::string& title, Gtk::MessageType messageType, Gtk::ButtonsType buttons) {
    std::unique_ptr<Gtk::MessageDialog> dialog(new Gtk::MessageDialog(message, false, messageType, buttons));
    dialog->set_title(title);
    return static_cast<Gtk::ResponseType>(dialog->run());
  }

  Gtk::ResponseType messageDialog(Gtk::Window& parent, const std::string& message, const std::string& title,
    Gtk::MessageType messageType, Gtk::ButtonsType buttons) {
    std::unique_ptr<Gtk::MessageDialog> dialog(new Gtk::MessageDialog(parent, message, false, messageType, buttons));
    dialog->set_title(title);
    return static_cast<Gtk::ResponseType>(dialog->run());
  }
} // namespace C8::Gtkmm
