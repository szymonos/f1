"""
common.py.

This module contains common functions used in other modules.
"""
from datetime import datetime

import numpy as np
import pandas as pd


def df_info(df: pd.DataFrame, clean: bool = False) -> pd.DataFrame:
    """
    Analyze DataFrame column definitions.

    Parameters
    ----------
    df : pandas.DataFrame
        Input DataFrame for analysis.
    clean : bool
        Whether to perform initial cleaning of DataFrame.

    Returns
    -------
    pandas.DataFrame
        Object with DataFrame analysis.

    """
    start = datetime.now()
    if clean:
        df.fillna(np.nan, inplace=True)  # replace None with np.nan
        df = df.applymap(
            lambda x: x.strip() if isinstance(x, str) else x
        )  # trim spaces
        df.replace("", np.nan, inplace=True)
    dmem = df.memory_usage(deep=True).to_dict()
    dmem.pop("Index", None)
    dnull = dict((v, df[v].isna().any()) for v in df.columns.values)
    dcnt = dict((v, len(df[v].dropna())) for v in df.columns.values)
    dunicode = dict(
        (
            v,
            df[v]
            .astype("object")
            .apply(
                lambda r: len(r) != len(r.encode())
                if isinstance(r, str)
                else False
            )
            .any(),
        )
        for v in df.columns.values
        if (df[v].notna().any() and df[v].dtypes.kind == "O")
    )
    dmin = dict(
        (v, df[v].min())
        for v in df.columns.values
        if (df[v].notna().any() and df[v].dtypes.kind not in ["O", "f"])
    )
    dmax = dict(
        (v, df[v].max())
        for v in df.columns.values
        if (df[v].notna().any() and df[v].dtypes.kind not in ["O", "f"])
    )
    dmin.update(
        dict(
            (v, int(df[v].min()))
            for v in df.columns.values
            if (df[v].notna().any() and df[v].dtypes.kind == "f")
        )
    )
    dmax.update(
        dict(
            (v, int(df[v].max()))
            for v in df.columns.values
            if (df[v].notna().any() and df[v].dtypes.kind == "f")
        )
    )
    dmin.update(
        dict(
            (
                v,
                df[v]
                .apply(lambda r: len(str(r)) if r is not np.nan else np.nan)
                .astype("Int32")
                .min(),
            )
            for v in df.columns.values
            if (df[v].notna().any() and df[v].dtypes.kind == "O")
        )
    )
    dmax.update(
        dict(
            (
                v,
                df[v]
                .apply(lambda r: len(str(r)) if r is not np.nan else np.nan)
                .astype("Int32")
                .max(),
            )
            for v in df.columns.values
            if (df[v].notna().any() and df[v].dtypes.kind == "O")
        )
    )
    dmode = dict(
        (v, df[v].mode()[0])
        for v in df.columns.values
        if (df[v].notna().any() and not df[v].is_unique)
    )
    dmodecnt = dict(
        (v, len(df[df[v] == df[v].mode()[0]]))
        for v in df.columns.values
        if df[v].notna().any()
    )
    dunique = dict(
        (v, len(df[v].unique())) for v in df.columns.values if df[v].notna().any()
    )
    desc = pd.DataFrame({"types": df.dtypes})
    desc["size"] = pd.Series(dmem)
    desc["isnull"] = pd.Series(dnull)
    desc["count"] = pd.Series(dcnt)
    desc["isunicode"] = pd.Series(dunicode)
    desc["min"] = pd.Series(dmin)
    desc["max"] = pd.Series(dmax)
    desc["mode"] = pd.Series(dmode)
    desc["mode_cnt"] = pd.Series(dmodecnt).astype("Int64")
    desc["uniq_cnt"] = pd.Series(dunique).astype("Int64")
    print(f"\033[92mElapsed time: {datetime.now() - start}\033[0m")
    return desc


def tidy_split(df, column, sep="|", keep=False):
    """
    Split the values of a column to rows.

    Expands column values so the new DataFrame has one split value per row.
    Filters rows where the column is missing.

    Parameters
    ----------
    df : pandas.DataFrame
        dataframe with the column to split and expand.
    column : str
        the column to split and expand
    sep : str
        the string used to split the column's values
    keep : bool
        whether to retain the presplit value as it's own row

    Returns
    -------
    pandas.DataFrame
        Returns a dataframe with the same columns as `df`.

    """
    indexes = list()
    new_values = list()
    df = df.dropna(subset=[column])
    for i, presplit in enumerate(df[column].astype(str)):
        values = presplit.split(sep)
        if keep and len(values) > 1:
            indexes.append(i)
            new_values.append(presplit)
        for value in values:
            indexes.append(i)
            new_values.append(value)
    new_df = df.iloc[indexes, :].copy()
    new_df[column] = new_values
    return new_df
