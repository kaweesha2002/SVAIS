import numpy as np
import scipy.signal

def compute_fft(signal, sampling_rate):
    """
    Compute the Fast Fourier Transform (FFT) of a signal.

    Parameters:
    signal (numpy.ndarray): The input signal.
    sampling_rate (int): The sampling rate of the signal.

    Returns:
    tuple: Frequencies and corresponding FFT values.
    """
    n = len(signal)
    fft_values = np.fft.fft(signal)
    fft_freq = np.fft.fftfreq(n, d=1/sampling_rate)
    return fft_freq, np.abs(fft_values)

def compute_rms(signal):
    """
    Compute the Root Mean Square (RMS) of a signal.

    Parameters:
    signal (numpy.ndarray): The input signal.

    Returns:
    float: The RMS value of the signal.
    """
    return np.sqrt(np.mean(signal**2))

def compute_zcr(signal):
    """
    Compute the Zero-Crossing Rate (ZCR) of a signal.

    Parameters:
    signal (numpy.ndarray): The input signal.

    Returns:
    float: The ZCR value of the signal.
    """
    zero_crossings = np.where(np.diff(np.sign(signal)))[0]
    return len(zero_crossings) / len(signal)

def compute_spectral_centroid(signal, sampling_rate):
    """
    Compute the Spectral Centroid of a signal.

    Parameters:
    signal (numpy.ndarray): The input signal.
    sampling_rate (int): The sampling rate of the signal.

    Returns:
    float: The spectral centroid of the signal.
    """
    fft_freq, fft_values = compute_fft(signal, sampling_rate)
    spectral_centroid = np.sum(fft_freq * fft_values) / np.sum(fft_values)
    return spectral_centroid

def envelope(signal):
    """
    Compute the envelope of a signal using the Hilbert transform.

    Parameters:
    signal (numpy.ndarray): The input signal.

    Returns:
    numpy.ndarray: The envelope of the signal.
    """
    analytic_signal = scipy.signal.hilbert(signal)
    return np.abs(analytic_signal)