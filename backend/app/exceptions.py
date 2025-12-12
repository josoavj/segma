"""
Exceptions personnalisées pour l'application SEGMA
"""


class SegmaException(Exception):
    """Exception de base pour l'application SEGMA"""
    pass


class ModelNotLoadedException(SegmaException):
    """Exception levée quand le modèle SAM n'est pas chargé"""
    pass


class ImageProcessingException(SegmaException):
    """Exception levée lors d'une erreur de traitement d'image"""
    pass


class SegmentationException(SegmaException):
    """Exception levée lors d'une erreur de segmentation"""
    pass


class InvalidCoordinatesException(SegmaException):
    """Exception levée quand les coordonnées sont invalides"""
    pass
