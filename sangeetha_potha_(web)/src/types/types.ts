export interface Artist {
  name: string;
  artistCoverUrl: string;
  id?: string;
}

export interface Song {
  title: string;
  songCoverUrl: string;
  lyrics: string;
  artistId: string;

  isFav: boolean;
  id?: string;
}