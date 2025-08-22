from PySide6.QtCore import QObject, Property, Signal, QSettings


class SettingsController(QObject):
    isThemeChanged = Signal()
    volumeChanged = Signal()
    vibrationEnabledChanged = Signal()

    def __init__(self):
        super().__init__()
        self._settings = QSettings("LudoBot", "LudoBot")
        self._volume = self._settings.value("volume", 50)
        self._vibration_enabled = self._settings.value("vibration_enabled", True)
        self._is_dark_mode = self._settings.value("is_dark_mode", False)
        self.isThemeChanged.emit()

    @Property(int, notify=volumeChanged)
    def volume(self):
        return self._volume

    @volume.setter
    def volume(self, value):
        if self._volume != value:
            self._volume = value
            self._settings.setValue("volume", value)
            self.volumeChanged.emit()

    @Property(bool, notify=vibrationEnabledChanged)
    def vibration_enabled(self):
        return self._vibration_enabled

    @vibration_enabled.setter
    def vibration_enabled(self, value):
        if self._vibration_enabled != value:
            self._vibration_enabled = value
            self._settings.setValue("vibration_enabled", value)
            self.vibrationEnabledChanged.emit()

    @Property(bool, notify=isThemeChanged)
    def is_dark_mode(self):
        return self._is_dark_mode

    @is_dark_mode.setter
    def is_dark_mode(self, value):
        self._is_dark_mode = value
        self._settings.setValue("is_dark_mode", value)
        self.isThemeChanged.emit()