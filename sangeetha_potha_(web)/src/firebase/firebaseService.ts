import { initializeApp } from 'firebase/app';
import { 
  getFirestore, 
  collection, 
  getDocs, 
  addDoc, 
  deleteDoc, 
  doc, 
  setDoc,
  serverTimestamp,
  Timestamp
} from 'firebase/firestore';
import { firebaseConfig } from './config';
import { Artist, Song } from '../types/types';

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

// Artists Collection
export const addArtist = async (artistId: string, artistData: Artist): Promise<void> => {
  try {
    await setDoc(doc(db, 'artists', artistId), artistData);
  } catch (error) {
    console.error('Error adding artist:', error);
    throw error;
  }
};

export const getArtists = async (): Promise<Artist[]> => {
  try {
    const artistsCol = collection(db, 'artists');
    const artistSnapshot = await getDocs(artistsCol);
    return artistSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    })) as Artist[];
  } catch (error) {
    console.error('Error getting artists:', error);
    throw error;
  }
};

export const deleteArtist = async (artistId: string): Promise<void> => {
  try {
    await deleteDoc(doc(db, 'artists', artistId));
  } catch (error) {
    console.error('Error deleting artist:', error);
    throw error;
  }
};

// Songs Collection
export const addSong = async (songData: Omit<Song, 'createdAt' | 'id'>): Promise<void> => {
  try {
    await addDoc(collection(db, 'songs'), {
      ...songData,
      createdAt: serverTimestamp()
    });
  } catch (error) {
    console.error('Error adding song:', error);
    throw error;
  }
};

export const getSongs = async (): Promise<Song[]> => {
  try {
    const songsCol = collection(db, 'songs');
    const songSnapshot = await getDocs(songsCol);
    return songSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    })) as Song[];
  } catch (error) {
    console.error('Error getting songs:', error);
    throw error;
  }
};

export const deleteSong = async (songId: string): Promise<void> => {
  try {
    await deleteDoc(doc(db, 'songs', songId));
  } catch (error) {
    console.error('Error deleting song:', error);
    throw error;
  }
};

export const formatTimestamp = (timestamp: Timestamp | null): string => {
  if (!timestamp) return 'N/A';
  return timestamp.toDate().toLocaleString();
};